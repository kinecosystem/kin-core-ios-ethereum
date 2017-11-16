//
//  KinClient.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

/**
 `KinClient` is a factory class for creating and obtaining an instance of `KinAccount`.
 */
public final class KinClient {
    static private let supportedNetworks = [
        NetworkId.mainNet,
        NetworkId.ropsten,
        NetworkId.truffle
    ]

    fileprivate(set) public lazy var account: KinAccount? = {
        if self.accountStore.accounts.size() > 0,
            let account = try? self.accountStore.accounts.get(0) {
            return KinAccount(gethAccount: account, accountStore: self.accountStore)
        }

        return nil
    }()

    fileprivate let accountStore: KinAccountStore

    public var networkId: NetworkId {
        return self.accountStore.networkId
    }

    public convenience init(provider: ServiceProvider) throws {
        try self.init(with: provider.url, networkId: provider.networkId)
    }

    public init(with nodeProviderUrl: URL, networkId: NetworkId) throws {
        if KinClient.supportedNetworks.contains(where: { $0 == networkId }) == false {
            throw KinError.unsupportedNetwork
        }

        self.accountStore = KinAccountStore(url: nodeProviderUrl, networkId: networkId)
    }

    public func createAccountIfNeeded(with passphrase: String) throws -> KinAccount {
        return try account ?? {
            let newAccount = try KinAccount(gethAccount: accountStore.createAccount(passphrase: passphrase),
                                            accountStore: accountStore)
            account = newAccount

            return newAccount
        }()
    }

    public func deleteAccount(with passphrase: String) throws {
        guard let gethAccount = account?.gethAccount else {
            return
        }

        try accountStore.delete(account: gethAccount, passphrase: passphrase)

        account = nil
    }

    public func exportKeyStore(passphrase: String, exportPassphrase: String) throws -> String? {
        guard let account = account else {
            return nil
        }

        let data = try accountStore.export(account: account.gethAccount,
                                           passphrase: passphrase,
                                           exportPassphrase: exportPassphrase)

        return String(data: data, encoding: String.Encoding.utf8)
    }
}

// MARK: - For testing only

extension KinClient {
    func deleteKeystore() {
        try? accountStore.deleteKeystore()
    }

    func createAccount(with privateKey: String, passphrase: String) throws -> KinAccount? {
        let index = privateKey.index(privateKey.startIndex, offsetBy: 2)
        if let gAccount = accountStore.importAccount(with: privateKey.substring(from: index), passphrase: passphrase) {
            account =  KinAccount(gethAccount: gAccount,
                                  accountStore: accountStore)
        }

        return account
    }
}
