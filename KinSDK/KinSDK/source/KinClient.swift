//
//  KinClient.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation
import StellarKinKit

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
        self.stellar = Stellar(baseURL: nodeProviderUrl,
                               kinIssuer: networkId.issuer)
        self.accounts = KinAccounts(stellar: stellar)

        self.networkId = networkId
    }

    /**
     The current account associated to this client.

     Returns `nil` if no account has been created yet, or if it was deleted.
     */
    @available(*, deprecated)
    public var account: KinAccount? {
        return accounts[0]
    }

    public var accounts: KinAccounts

    internal let stellar: Stellar

    /**
     The `NetworkId` of the network which this client communicates to.
     */
    public let networkId: NetworkId

    /**
     Creates an account associated to this client. If one or more accounts already exist, the
     first account is returned.

     - parameter passphrase: The passphrase to use in order to create the associated account.

     - throws: If creating the account fails.
     */
    @available(*, deprecated)
    public func createAccountIfNeeded(with passphrase: String) throws -> KinAccount {
        return try accounts[0] ?? accounts.createAccount(with: passphrase)
    }

    /**
     Adds an account associated to this client, and returns it.

     - parameter passphrase: The passphrase to use in order to create the associated account.

     - throws: If creating the account fails.
     */
    public func addAccount(with passphrase: String) throws -> KinAccount {
        return try accounts.createAccount(with: passphrase)
    }

    /**
     Deletes the account at index 0. This method is a no-op in case there are no accounts.

     If this is an action triggered by the user, make sure you let the him know that any funds owned
     by the account will be lost if it hasn't been backed up. See
     `exportKeyStore(passphrase:exportPassphrase:)`.

     - parameter passphrase: The passphrase used to create the associated account.

     - throws: If the passphrase is invalid, or if deleting the account fails.
     */
    @available(*, deprecated)
    public func deleteAccount(with passphrase: String) throws {
        try accounts.deleteAccount(at: 0, with: passphrase)
    }

    /**
     Deletes the account at the given index. This method is a no-op if there is no account at
     that index.

     If this is an action triggered by the user, make sure you let the him know that any funds owned
     by the account will be lost if it hasn't been backed up. See
     `exportKeyStore(passphrase:exportPassphrase:)`.

     - parameter index: The index of the account to delete.
     - parameter passphrase: The passphrase used to create the associated account.

     - throws: If the passphrase is invalid, or if deleting the account fails.
     */
    public func deleteAccount(at index: Int, with passphrase: String) throws {
        try accounts.deleteAccount(at: index, with: passphrase)
    }

    /**
     Deletes the keystore.
     */
    public func deleteKeystore() {
        for _ in 0..<KeyStore.count() {
            KeyStore.remove(at: 0)
        }

        accounts.flushCache()
    }
}
