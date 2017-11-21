//
//  KinAccount.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation
import KinSDKPrivate

public class KinAccount {
    internal let gethAccount: GethAccount
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
                                kin: UInt64,
                                passphrase: String,
                                completion: @escaping TransactionCompletion) {
        accountQueue.async {
            do {
                let transactionId = try self.sendTransaction(to: to,
                                                             kin: kin,
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

        guard let addressFromHex = GethNewAddressFromHex(to, nil) else {
            throw KinError.invalidAddress
        }

        guard kin > 0 else {
            throw KinError.invalidAmount
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
        toAddress.setAddress(addressFromHex)
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
