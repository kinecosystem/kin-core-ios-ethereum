//
//  KinAccount.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation
import StellarKinKit

/**
 `KinAccount` represents an account which holds Kin. It allows checking balance and sending Kin to
 other accounts.
 */
public protocol KinAccount {
    /**
     The public address of this account. If the user wants to receive KIN by sending his address
     manually to someone, or if you want to display the public address, use this property.
     */
    var publicAddress: String { get }

    /**
     **Asynchronously** posts a Kin transfer to a specific address.

     The completion block is called after the transaction is posted on the network, which is prior
     to confirmation.

     The completion block **is not dispatched on the main thread**.

     - parameter recipient: The recipient's public address
     - parameter kin: The amount of Kin to be sent
     - parameter passphrase: The passphrase used to generate the `KinAccount`
     */
    func sendTransaction(to recipient: String,
                         kin: UInt64,
                         passphrase: String,
                         completion: @escaping TransactionCompletion)

    /**
     **Synchronously** posts a Kin transfer to a specific address.

     This function returns after the transaction is posted on the network, which is prior to
     confirmation.

     Don't call this method from the main thread.

     - parameter recipient: The recipient's public address
     - parameter kin: The amount of Kin to be sent
     - parameter passphrase: The passphrase used to generate the `KinAccount`

     - throws: An `Error` if the transaction fails to be generated or submitted

     - returns: The `TransactionId` in case of success.
     */
    func sendTransaction(to recipient: String, kin: UInt64, passphrase: String) throws -> TransactionId

    /**
     **Asynchronously** gets the current Kin balance. **Does not** take into account
     transactions pending confirmations. The completion block **is not dispatched on the main thread**.

     - parameter completion: A callback block to be invoked once the balance is fetched, or fails to
     be fetched.
     */
    func balance(completion: @escaping BalanceCompletion)

    /**
     **Synchronously** gets the current Kin balance. **Does not** take into account
     transactions pending confirmations.

     **Do not** call this from the main thread.

     - throws: An `Error` if balance cannot be fetched.

     - returns: The `Balance` of the account.
     */
    func balance() throws -> Balance

    /**
     **Deprecated**: this method returns the result of `balance(completion:)`.

     - parameter completion: A callback block to be invoked once the pending balance is fetched, or
     fails to be fetched.
     */
    @available(*, deprecated)
    func pendingBalance(completion: @escaping BalanceCompletion)

    /**
     **Deprecated**: this method returns the result of `balance()`.

     **Do not** call this from the main thread.

     - throws: An `Error` if balance cannot be fetched.

     - returns: The pending balance of the account.
     */
    @available(*, deprecated)
    func pendingBalance() throws -> Balance

    /**
     Exports this account as a Key Store JSON string, to be backed up by the user.

     - parameter passphrase: The passphrase used to create the associated account.
     - parameter exportPassphrase: A new passphrase, to encrypt the Key Store JSON.

     - throws: If the passphrase is invalid, or if exporting the associated account fails.

     - returns: a prettified JSON string of the `account` exported; `nil` if `account` is `nil`.
     */
    func exportKeyStore(passphrase: String, exportPassphrase: String) throws -> String?

    /**
     :nodoc
     */
    func fund(completion: @escaping (Bool) -> Void)

    /**
     :nodoc
     */
    func trustKIN(passphrase: String, completion: @escaping (String?, Error?) -> Void)
}

final class KinStellarAccount: KinAccount {
    internal let stellarAccount: StellarAccount
    fileprivate weak var stellar: Stellar?

    let KinMultiplier: UInt64 = 10000000

    var deleted = false

    var publicAddress: String {
        return stellarAccount.publicKey!
    }

    init(stellarAccount: StellarAccount, stellar: Stellar) {
        self.stellarAccount = stellarAccount
        self.stellar = stellar
    }

    func sendTransaction(to recipient: String, kin: UInt64, passphrase: String, completion: @escaping TransactionCompletion) {
        guard let stellar = stellar else {
            completion(nil, KinError.internalInconsistency)

            return
        }

        guard deleted == false else {
            completion(nil, KinError.accountDeleted)

            return
        }

        guard kin > 0 else {
            completion(nil, KinError.invalidAmount)

            return
        }

        stellar.payment(source: stellarAccount,
                        destination: recipient,
                        amount: Int64(kin * KinMultiplier),
                        passphrase: passphrase) { (txHash, error) in
                            completion(txHash, error)
        }
    }

    func sendTransaction(to recipient: String, kin: UInt64, passphrase: String) throws -> TransactionId {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        var errorToThrow: Error? = nil
        var txHashToReturn: TransactionId? = nil

        sendTransaction(to: recipient, kin: kin, passphrase: passphrase) { txHash, error in
            errorToThrow = error
            txHashToReturn = txHash

            dispatchGroup.leave()
        }

        dispatchGroup.wait()

        if let error = errorToThrow {
            throw error
        }

        guard let txHash = txHashToReturn else {
            throw KinError.unknown
        }

        return txHash
    }

    func balance(completion: @escaping BalanceCompletion) {
        guard let stellar = stellar else {
            completion(nil, KinError.internalInconsistency)

            return
        }

        guard deleted == false else {
            completion(nil, KinError.accountDeleted)

            return
        }

        stellar.balance(account: stellarAccount.publicKey!, completion: completion)
    }

    func balance() throws -> Balance {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        var errorToThrow: Error? = nil
        var balanceToReturn: Balance? = nil

        balance { (balance, error) in
            errorToThrow = error
            balanceToReturn = balance

            dispatchGroup.leave()
        }

        dispatchGroup.wait()

        if let error = errorToThrow {
            throw error
        }

        guard let balance = balanceToReturn else {
            throw KinError.unknown
        }

        return balance
    }

    @available(*, deprecated)
    func pendingBalance(completion: @escaping BalanceCompletion) {
        balance(completion: completion)
    }

    @available(*, deprecated)
    func pendingBalance() throws -> Balance {
        return try balance()
    }

    @available(*, unavailable)
    internal func exportKeyStore(passphrase: String, exportPassphrase: String) throws -> String? {
        let accountData = KeyStore.exportAccount(account: stellarAccount, passphrase: passphrase, newPassphrase: exportPassphrase)

        guard let store = accountData else {
            throw KinError.internalInconsistency
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: store,
                                                         options: [.prettyPrinted])
            else {
                return nil
        }

        return String(data: jsonData, encoding: .utf8)
    }
}

// For testing

extension KinStellarAccount {
    public func fund(completion: @escaping (Bool) -> Void) {
        guard let stellar = stellar else {
            completion(false)

            return
        }

        stellar.fund(account: stellarAccount.publicKey!, completion: completion)
    }

    public func trustKIN(passphrase: String, completion: @escaping (String?, Error?) -> Void) {
        guard let stellar = stellar else {
            completion(nil, KinError.internalInconsistency)

            return
        }

        stellar.trust(asset: stellar.asset,
                      account: stellarAccount,
                      passphrase: passphrase,
                      completion: completion)
    }
}
