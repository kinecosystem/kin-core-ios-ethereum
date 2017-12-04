//
//  KinClient.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

/**
 `KinClient` is a factory class for managing an instance of `KinAccount`.
 */
public final class KinClient {
    /**
     Convenience initializer to instantiate a `KinClient` with a `ServiceProvider`.

     - parameter provider: The `ServiceProvider` instance that provides the `URL` and `NetworkId`.
     */
    public convenience init(provider: ServiceProvider) throws {
        try self.init(with: provider.url, networkId: provider.networkId)
    }

    /**
     Instantiates a `KinClient` with a `URL` and a `NetworkId`.

     - parameter nodeProviderUrl: The `URL` of the node this client will communicate to.
     - parameter networkId: The `NetworkId` to be used.
     */
    public init(with nodeProviderUrl: URL, networkId: NetworkId) throws {
        self.accountStore = KinAccountStore(url: nodeProviderUrl, networkId: networkId)
    }

    /**
     The current account associated to this client.

     Returns `nil` if no account has been created yet, or if it was deleted.
     */
    fileprivate(set) public lazy var account: KinAccount? = {
        if self.accountStore.accounts.size() > 0,
            let account = try? self.accountStore.accounts.get(0) {
            return KinEthereumAccount(gethAccount: account, accountStore: self.accountStore)
        }

        return nil
    }()

    fileprivate let accountStore: KinAccountStore

    /**
     The `NetworkId` of the network which this client communicates to.
     */
    public var networkId: NetworkId {
        return self.accountStore.networkId
    }

    /**
     Creates an account associated to this client. If this method was previously called and
     `account` already exists, it is returned instead.

     - parameter passphrase: The passphrase to use in order to create the associated account.

     - throws: If creating the account fails.
     */
    public func createAccountIfNeeded(with passphrase: String) throws -> KinAccount {
        return try account ?? {
            let newAccount = try KinEthereumAccount(gethAccount: accountStore.createAccount(passphrase: passphrase),
                                                    accountStore: accountStore)
            account = newAccount

            return newAccount
        }()
    }

    /**
     Deletes the current account associated to this client. This method is a no-op in case the
     `account` is `nil`. In case it succeeds, `account` becomes `nil`.

     If this is an action triggered by the user, make sure you let the him know that any funds owned
     by the account will be lost if it hasn't been backed up. See
     `exportKeyStore(passphrase:exportPassphrase:)`.

     - parameter passphrase: The passphrase used to create the associated account.

     - throws: If the passphrase is invalid, or if deleting the account fails.
     */
    public func deleteAccount(with passphrase: String) throws {
        guard let gethAccount = (account as? KinEthereumAccount)?.gethAccount else {
            return
        }

        try accountStore.delete(account: gethAccount, passphrase: passphrase)

        (account as? KinEthereumAccount)?.deleted = true
        account = nil
    }

    /**
     Exports this account as a Key Store JSON string, to be backed up by the user.

     - parameter passphrase: The passphrase used to create the associated account.
     - parameter exportPassphrase: A new passphrase, to encrypt the Key Store JSON.

     - throws: If the passphrase is invalid, or if exporting the associated account fails.

     - returns: a prettified JSON string of the `account` exported; `nil` if `account` is `nil`.
     */
    public func exportKeyStore(passphrase: String, exportPassphrase: String) throws -> String? {
        guard let account = account as? KinEthereumAccount else {
            return nil
        }

        let data = try accountStore.export(account: account.gethAccount,
                                           passphrase: passphrase,
                                           exportPassphrase: exportPassphrase)

        return String(data: data, encoding: String.Encoding.utf8)
    }

    public func status(for transactionId: TransactionId) throws -> TransactionStatus {
        do {
            _ = try accountStore.transactionReceipt(for: transactionId)
        }
        catch {
            let nsError = error as NSError

            if nsError.domain == "go" && nsError.code == 1 {
                return .pending
            }

            throw error
        }

        return .complete
    }

    /**
     Deletes the keystore.
     */
    public func deleteKeystore() throws {
        try accountStore.deleteKeystore()

        (account as? KinEthereumAccount)?.deleted = true
        account = nil
    }
}

// MARK: - For testing only

extension KinClient {
    func createAccount(with privateKey: String, passphrase: String) throws -> KinAccount? {
        let index = privateKey.index(privateKey.startIndex, offsetBy: 2)
        if let gAccount = accountStore.importAccount(with: privateKey.substring(from: index), passphrase: passphrase) {
            account =  KinEthereumAccount(gethAccount: gAccount,
                                          accountStore: accountStore)
        }

        return account
    }

    func createAccount(with passphrase: String) throws -> KinAccount {
        return try KinEthereumAccount(gethAccount: accountStore.createAccount(passphrase: passphrase),
                                      accountStore: accountStore)
    }
}
