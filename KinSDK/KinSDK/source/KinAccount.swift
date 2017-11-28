//
//  KinAccount.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation
import KinSDKPrivate

/**
 `KinAccount` represents an account which holds Kin. It allows checking balance and sending Kin to
 other accounts.
 */
public final class KinAccount {
    internal let gethAccount: GethAccount
    fileprivate weak var accountStore: KinAccountStore?
    fileprivate let contract: Contract
    fileprivate let accountQueue = DispatchQueue(label: "com.kik.kin.account")

    /**
     The public address of this account. If the user wants to receive KIN by sending his address
     manually to someone, or if you want to display the public address, use this property.
     */
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

    /**
     **Asynchronously** posts a Kin transfer to a specific address.

     The completion block is called after the transaction is posted on the network, which is prior
     to confirmation.

     The completion block **is not dispatched on the main thread**.

     - parameter recipient: The recipient's public address
     - parameter kin: The amount of Kin to be sent
     - parameter passphrase: The passphrase used to generate the `KinAccount`
     */
    public func sendTransaction(to recipient: String,
                                kin: UInt64,
                                passphrase: String,
                                completion: @escaping TransactionCompletion) {
        accountQueue.async {
            do {
                let transactionId = try self.sendTransaction(to: recipient,
                                                             kin: kin,
                                                             passphrase: passphrase)
                completion(transactionId, nil)
            }
            catch {
                completion(nil, error)
            }
        }
    }

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
    @discardableResult public func sendTransaction(to recipient: String,
                                                   kin: UInt64,
                                                   passphrase: String) throws -> TransactionId {
        guard kin > 0 else {
            throw KinError.invalidAmount
        }

        guard let addressFromHex = GethNewAddressFromHex(recipient, nil) else {
            throw KinError.invalidAddress
        }

        guard let store = accountStore else {
            throw KinError.internalInconsistency
        }

        guard
            let wei = Decimal(kin).kinToWei().toBigInt(),
            let options = GethTransactOpts(),
            let price = try? store.client.suggestGasPrice(store.context),
            let toAddress = GethNewInterface(),
            let value = GethNewInterface() else {
                throw KinError.internalInconsistency
        }

        let currentBalance = (try balance() as NSDecimalNumber).uint64Value

        if currentBalance < kin {
            throw KinError.insufficientBalance
        }

        let nonce: UnsafeMutablePointer<Int64> = UnsafeMutablePointer<Int64>.allocate(capacity: 1)
        defer {
            _ = UnsafeMutablePointer<Int64>.deallocate(nonce)
        }

        try store.client.getPendingNonce(at: store.context, account: gethAccount.getAddress(), nonce: nonce)

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

    /**
     **Asynchronously** gets the current Kin balance. **Does not** take into account
     transactions pending confirmations. The completion block **is not dispatched on the main thread**.

     - parameter completion: A callback block to be invoked once the balance is fetched, or fails to
     be fetched.
     */
    public func balance(completion: @escaping BalanceCompletion) {
        accountQueue.async {
            do {
                let balance = try self.balance()
                completion(balance, nil)
            }
            catch {
                completion(nil, error)
            }
        }
    }

    /**
     **Synchronously** gets the current Kin balance. **Does not** take into account
     transactions pending confirmations.

     **Do not** call this from the main thread.

     - throws: An `Error` if balance cannot be fetched.

     - returns: The `Balance` of the account.
     */
    public func balance() throws -> Balance {
        let arg = GethNewInterface()!
        arg.setAddress(gethAccount.getAddress())
        let result = GethNewInterface()!
        result.setDefaultBigInt()

        try self.contract.call(method: "balanceOf", inputs: [arg], outputs: [result])

        guard let balance = Decimal(bigInt: result.getBigInt())?.weiToKin() else {
            throw KinError.internalInconsistency
        }

        return balance
    }

    /**
     **Synchronously** gets the current **pending** Kin balance.

     Please note that this is not the sum of pending transactions, but the **current balance plus
     the sum of pending transactions.**

     The completion block **is not dispatched on the main thread**.

     - parameter completion: A callback block to be invoked once the pending balance is fetched, or
     fails to be fetched.
     */
    public func pendingBalance(completion: @escaping BalanceCompletion) {
        accountQueue.async {
            do {
                let balance = try self.pendingBalance()
                completion(balance, nil)
            }
            catch {
                completion(nil, error)
            }
        }
    }

    /**
     **Synchronously** gets the current **pending** Kin balance.

     Please note that this is not the sum of pending transactions, but the **current balance plus
     the sum of pending transactions.**

     **Do not** call this from the main thread.

     - throws: An `Error` if balance cannot be fetched.

     - returns: The pending balance of the account.
     */
    public func pendingBalance() throws -> Balance {
        let balance = try self.balance().kinToWei()

        let sentLogs = try contract.pendingTransactionLogs(from: gethAccount.getAddress().getHex(),
                                                           to: nil)
        let sent = try sumTransactionAmount(logs: sentLogs)

        let earnedLogs = try contract.pendingTransactionLogs(from: nil,
                                                             to: gethAccount.getAddress().getHex())
        let earned = try sumTransactionAmount(logs: earnedLogs)

        return (balance + earned - sent).weiToKin()
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

extension KinAccount {
    func decimals() throws -> UInt8 {
        let result = GethNewInterface()!
        result.setDefaultUint8()
        try contract.call(method: "decimals", outputs: [result])
        return UInt8(result.getUint8().getInt64())
    }
}
