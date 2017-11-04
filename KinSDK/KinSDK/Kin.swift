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
    
    private(set) lazy var account: KinAccount? = {
        if self.accountStore.accounts.size() > 0 {
            if let account = try? self.accountStore.accounts.get(0) {
                return KinAccount(gethAccount: account, accountStore: self.accountStore)
            }
        }
        return nil
    }()

    fileprivate let accountStore: KinAccountStore
    fileprivate let queue = DispatchQueue(label: "com.kik.kin.account")

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
    
    // TODO: move to own Contract implementation
    fileprivate var _contract: GethBoundContract? = nil
    fileprivate var testTokenContract: GethBoundContract? {
        if _contract != nil {
            return _contract
        }

        guard let store = accountStore else {
            return nil
        }

        _contract = GethBindContract(KinResources.RopstenTestTokenContractAddress,
                                     KinResources.RopstenTestTokenAbi,
                                     store.client, nil)

        return _contract
    }

    var publicAddress: String {
        return gethAccount.getAddress().getHex()
    }

    init(gethAccount: GethAccount, accountStore: KinAccountStore) {
        self.gethAccount = gethAccount
        self.accountStore = accountStore
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

    public func balance(callback: BalanceCallback) {
        callback(nil, nil)
    }

    public func balance() throws -> Balance {
        
//        let context = accountStore.context
//        let client = accountStore.client
//        let contract = testTokenContract
//        let opts = GethNewCallOpts()!
//        opts.setContext(context)
//        opts.setGasLimit((try! client.suggestGasPrice(context).getInt64()))
//        let args = GethNewInterfaces(1)!
//        let outs = GethNewInterfaces(1)!
//
//        let arg = GethNewInterface()!
//        arg.setAddress(gethAccount.getAddress())
//        let result = GethNewInterface()
//        result?.setDefaultBigInt()
//        try! args.set(0, object: arg)
//        try! outs.set(0, object: result)
//
//        do {
//            try contract.call(opts, out_: outs, method: "balanceOf", args: args)
//            return try! outs.get(0).getBigInt().getInt64()
//        } catch let e {
//            print(e)
//        }
        return 0
    }

    public func pendingBalance(callback: BalanceCallback) {
        callback(nil, nil)
    }

    public func pendingBalance() throws -> Balance {
        return 0
    }
}
