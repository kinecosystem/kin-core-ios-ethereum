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
}

public final class KinClient {
    private(set) var account: KinAccount?

    fileprivate let accountStore: KinAccountStore

    public convenience init(provider: ServiceProvider) {
        self.init(with: provider.url, networkId: provider.networkId)
    }

    public init(with nodeProviderUrl: URL, networkId: Int64) {
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
public typealias BalanceCallback = (Balance?, KinError?) -> ()

public class KinAccount {
    fileprivate let gethAccount: GethAccount
    fileprivate weak var accountStore: KinAccountStore?

    var publicAddress: String {
        return ""
    }

    init(gethAccount: GethAccount, accountStore: KinAccountStore) {
        self.gethAccount = gethAccount
        self.accountStore = accountStore
    }

    func privateKey(with passphrase: String) throws -> String? {
        guard let data = try accountStore?.export(account: gethAccount,
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

    public func balance(callback: BalanceCallback) {
        callback(nil, nil)
    }

    public func balance() throws -> Balance {
        return 0
    }

    public func pendingBalance(callback: BalanceCallback) {
        callback(nil, nil)
    }

    public func pendingBalance() throws -> Balance {
        return 0
    }
}
