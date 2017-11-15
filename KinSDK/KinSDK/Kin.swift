//
//  Kin.swift
//  KinSDK
//
//  Created by Avi Shevin on 31/10/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

public protocol ServiceProvider {
    var url: URL { get }
    var networkId: UInt64 { get }
}

public struct InfuraProvider: ServiceProvider {
    public let url: URL
    public let networkId: UInt64

    init(url: URL, networkId: UInt64, apiKey: String) {
        self.url = URL(string: apiKey, relativeTo: url)!
        self.networkId = networkId
    }
}

public struct InfuraTestProvider: ServiceProvider {
    public let url: URL
    public let networkId: UInt64

    public init(apiKey: String) {
        self.url = URL(string: apiKey, relativeTo: URL(string: "https://ropsten.infura.io")!)!
        self.networkId = 3
    }
}

public enum KinError: Error {
    case unknown
    case invalidInput
    case internalInconsistancy
    case invalidPassphrase
    case unsupportedNetwork
}

public let NetworkIdMain: UInt64 = 1
public let NetworkIdRopsten: UInt64 = 3

public final class KinClient {
    static private let supportedNetworks = [
        NetworkIdMain,
        NetworkIdRopsten,
    ]

    private(set) lazy var account: KinAccount? = {
        if self.accountStore.accounts.size() > 0 {
            if let account = try? self.accountStore.accounts.get(0) {
                return KinAccount(gethAccount: account, accountStore: self.accountStore)
            }
        }
        return nil
    }()

    fileprivate let accountStore: KinAccountStore

    public convenience init(provider: ServiceProvider) throws {
        try self.init(with: provider.url, networkId: provider.networkId)
    }

    public init(with nodeProviderUrl: URL, networkId: UInt64) throws {
        if KinClient.supportedNetworks.contains(networkId) == false {
            throw KinError.unsupportedNetwork
        }

        self.accountStore = KinAccountStore(url: nodeProviderUrl, networkId: networkId)
    }

    public func createAccountIfNeeded(with passphrase: String) throws -> KinAccount? {
        if accountStore.accounts.size() == 0 {
            account = try KinAccount(gethAccount: accountStore.createAccount(passphrase: passphrase),
                                     accountStore: accountStore)
        }

        return account
    }

    func keyStore(with passphrase: String) throws -> String? {
        guard let account = account else {
            return nil
        }

        let data = try accountStore.export(account: account.gethAccount,
                                           passphrase: passphrase,
                                           exportPassphrase: passphrase)

        return String(data: data, encoding: String.Encoding.utf8)
    }
}

public typealias Balance = Decimal
public typealias TransactionId = String

public typealias TransactionCompletion = (TransactionId?, Error?) -> ()
public typealias BalanceCompletion = (Balance?, Error?) -> ()

class TransactionSigner: NSObject, GethSignerProtocol {

    fileprivate weak var keyStore: GethKeyStore?
    fileprivate weak var account: GethAccount?
    fileprivate var passphrase: String
    fileprivate var networkId: UInt64

    init(with keyStore: GethKeyStore, account: GethAccount, passphrase: String,  networkId: UInt64) {
        self.keyStore = keyStore
        self.account = account
        self.networkId = networkId
        self.passphrase = passphrase
        super.init()
    }

    func sign(_ p0: GethAddress!, p1: GethTransaction!) throws -> GethTransaction {
        guard   let keyStore = keyStore,
                let account = account else {
                    throw KinError.internalInconsistancy

        }
        return try keyStore.signTxPassphrase(account, passphrase: passphrase, tx: p1, chainID: GethNewBigInt(Int64(networkId)))
    }

}

public class KinAccount {

    fileprivate let gethAccount: GethAccount
    fileprivate weak var accountStore: KinAccountStore?
    fileprivate let contract: Contract
    fileprivate let accountQueue = DispatchQueue(label: "com.kik.kin.account")

    public var publicAddress: String {
        return gethAccount.getAddress().getHex()
    }

    init(gethAccount: GethAccount, accountStore: KinAccountStore) {
        self.gethAccount = gethAccount
        self.accountStore = accountStore
        self.contract = Contract(with: accountStore.context,
                                 networkId: accountStore.networkId,
                                 client: accountStore.client)
    }

    func decimals() throws -> UInt8 {
        let result = GethNewInterface()!
        result.setDefaultUint8()
        try contract.call(method: "decimals", outputs: [result])
        return UInt8(result.getUint8().getInt64())
    }

    public func sendTransaction(to: String,
                                amount: UInt64,
                                passphrase: String,
                                completion: @escaping TransactionCompletion) {
        accountQueue.async {
            do {
                let transactionId = try self.sendTransaction(to: to,
                                                             kin: amount,
                                                             passphrase: passphrase)
                completion(transactionId, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    public func sendTransaction(to: String, kin: UInt64, passphrase: String) throws -> TransactionId {
        guard let store = accountStore else {
            throw KinError.internalInconsistancy
        }

        let nonce: UnsafeMutablePointer<Int64> = UnsafeMutablePointer<Int64>.allocate(capacity: 1)
        defer {
            _ = UnsafeMutablePointer<Int64>.deallocate(nonce)
        }

        try store.client.getPendingNonce(at: store.context, account: gethAccount.getAddress(), nonce: nonce)

        guard
            let wei = Decimal(kin).kinToWei().toBigInt(),
            let options = GethTransactOpts(),
            let price = try? store.client.suggestGasPrice(store.context),
            let toAddress = GethNewInterface(),
            let value = GethNewInterface() else {
                throw KinError.internalInconsistancy
        }

        options.setContext(store.context)
        options.setGasLimit(Contract.defaultGasLimit)
        options.setGasPrice(price)
        options.setNonce(nonce.pointee)
        options.setFrom(gethAccount.getAddress())

        let signer = TransactionSigner(with: store.keystore,
                                       account: gethAccount,
                                       passphrase: passphrase,
                                       networkId: store.networkId)

        options.setSigner(signer)
        toAddress.setAddress(GethNewAddressFromHex(to, nil))
        value.setBigInt(wei)

        let transaction = try self.contract.transact(method: "transfer",
                                                 options: options,
                                                 parameters: [toAddress, value])

        return transaction.getHash().getHex()
    }

    public func balance(completion: @escaping BalanceCompletion) {
        accountQueue.async {
            do {
                let balance = try self.balance()
                completion(balance, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    public func balance() throws -> Balance {
        let arg = GethNewInterface()!
        arg.setAddress(gethAccount.getAddress())
        let result = GethNewInterface()!
        result.setDefaultBigInt()
        try self.contract.call(method: "balanceOf", inputs: [arg], outputs: [result])

        guard let balance = Decimal(bigInt: result.getBigInt())?.weiToKin() else {
            throw KinError.internalInconsistancy
        }

        return balance
    }

    public func pendingBalance(completion: @escaping BalanceCompletion) {
        accountQueue.async {
            do {
                let balance = try self.pendingBalance()
                completion(balance, nil)
            } catch {
                completion(nil, error)
            }
        }
    }

    public func pendingBalance() throws -> Balance {
        let balance = try self.balance().kinToWei()
        let sent = try pendingSentBalance()
        let earned = try pendingEarnedBalance()

        return (balance + earned - sent).weiToKin()
    }

    fileprivate func pendingSentBalance() throws -> Balance {
        let logs = try contract.pendingTransactionLogs(from: gethAccount.getAddress().getHex(), to: nil)

        return try sumTransactionAmount(logs: logs)
    }

    fileprivate func pendingEarnedBalance() throws -> Balance {
        let logs = try contract.pendingTransactionLogs(from: nil, to: gethAccount.getAddress().getHex())

        return try sumTransactionAmount(logs: logs)
    }

    fileprivate func sumTransactionAmount(logs: GethLogs) throws -> Balance {
        var total: Decimal = 0

        for i in 0..<logs.size() {
            if let log = try? logs.get(i),
                log.getTxHash().getHex() != nil,
                let logData = log.getData(),
                let bigInt = GethNewBigInt(0) {
                bigInt.setBytes(logData)

                if let b = Decimal(bigInt: bigInt) {
                    total += b
                }
            }
        }

        return total
    }
}
