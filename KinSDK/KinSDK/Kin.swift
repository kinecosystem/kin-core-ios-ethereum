//
//  Kin.swift
//  KinSDK
//
//  Created by Avi Shevin on 31/10/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation
import Geth

public protocol ServiceProvider {
    var url: URL { get }
    var networkId: Int64 { get }
}

public struct InfuraProvider: ServiceProvider {
    public let url: URL
    public let networkId: Int64

    init(url: URL, networkId: Int64, apiKey: String) {
        self.url = URL(string: apiKey, relativeTo: url)!
        self.networkId = networkId
    }
}

public struct InfuraTestProvider: ServiceProvider {
    public let url: URL
    public let networkId: Int64

    init(apiKey: String) {
        self.url = URL(string: apiKey, relativeTo: URL(string: "https://ropsten.infura.io")!)!
        self.networkId = 3
    }
}

public enum KinError: Error {
    case unknown
    case invalidPassphrase
    case unsupportedNetwork
}

public let NetworkIdMain: Int64 = 1
public let NetworkIdRopsten: Int64 = 3

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

    public init(with nodeProviderUrl: URL, networkId: Int64) throws {
        if KinClient.supportedNetworks.contains(networkId) == false {
            throw KinError.unsupportedNetwork
        }

        self.accountStore = KinAccountStore(url: nodeProviderUrl, networkId: networkId)
    }

    public func createAccountIfNecessary(with passphrase: String) throws -> KinAccount? {
        if accountStore.accounts.size() == 0 {
            account = try KinAccount(gethAccount: accountStore.createAccount(passphrase: passphrase),
                                     accountStore: accountStore)
        }

        return account
    }
}

public typealias Balance = Double
public typealias TransactionId = String

public typealias TransactionCallback = (TransactionId?, KinError?) -> ()
public typealias BalanceCallback = (Balance?, Error?) -> ()

public class KinAccount {
    
    fileprivate let gethAccount: GethAccount
    fileprivate weak var accountStore: KinAccountStore?
    fileprivate let contract: Contract
    fileprivate let accountQueue = DispatchQueue(label: "com.kik.kin.account")

    var publicAddress: String {
        return gethAccount.getAddress().getHex()
    }

    init(gethAccount: GethAccount, accountStore: KinAccountStore) {
        self.gethAccount = gethAccount
        self.accountStore = accountStore
        self.contract = Contract(with: accountStore.context, client: accountStore.client)
    }
    
    func decimals() throws -> UInt8 {
        let result = GethNewInterface()!
        result.setDefaultUint8()
        try contract.call(method: "decimals", outputs: [result])
        return UInt8(result.getUint8().getInt64())
    }
    
    func privateKey(with passphrase: String) throws -> String? {
        guard let store = accountStore else {
            return nil
        }

        guard let data = try? store.export(account: gethAccount,
                                           passphrase: passphrase,
                                           exportPassphrase: passphrase) else {
                                            return nil
        }

        return String(data: data, encoding: String.Encoding.utf8)
    }

    public func sendTransaction(to: String,
                                amount: Double,
                                passphrase: String,
                                callback: TransactionCallback) {
        callback(nil, nil)
    }

    public func sendTransaction(to: String, amount: Double, passphrase: String) throws -> TransactionId {
        return ""
    }

    public func balance(callback: @escaping BalanceCallback) {
        
        accountQueue.async {
            do {
                let balance = try self.balance()
                callback(balance, nil)
            } catch {
                callback(nil, error)
            }
        }
        
    }
    
    public func balance() throws -> Balance {
        
        let arg = GethNewInterface()!
        arg.setAddress(self.gethAccount.getAddress())
        let result = GethNewInterface()!
        result.setDefaultBigInt()
        try self.contract.call(method: "balanceOf", inputs: [arg], outputs: [result])
        return Double(result.getBigInt().getInt64())
        
    }

    public func pendingBalance(callback: BalanceCallback) {
        callback(nil, nil)
    }

    public func pendingBalance() throws -> Balance {
        return 0
    }
}
