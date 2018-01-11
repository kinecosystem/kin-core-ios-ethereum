//
//  KinAccountTests.swift
//  KinTestHostTests
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinSDK
@testable import StellarKinKit
import Geth

class KinAccountTests: XCTestCase {

    var kinClient: KinClient!
    let passphrase = UUID().uuidString

    let node = NodeProvider(networkId: .testNet)

    var account0: KinAccount?
    var account1: KinAccount?
    var issuer: StellarAccount?

    override func setUp() {
        super.setUp()

        kinClient = try! KinClient(provider: node)

        KeyStore.removeAll()

        if KeyStore.count() > 0 {
            XCTAssertTrue(false, "Unable to clear existing accounts!")
        }

        self.account0 = try? kinClient.addAccount(with: passphrase)
        self.account1 = try? kinClient.addAccount(with: passphrase)

        if account0 == nil || account1 == nil {
            XCTAssertTrue(false, "Unable to create account(s)!")
        }

        issuer = try? KeyStore.importSecretSeed("SCML43HASLG5IIN34KCJLDQ6LPWYQ3HIROP5CRBHVC46YRMJ6QLOYQJS",
                                                passphrase: passphrase)

        if issuer == nil {
            XCTAssertTrue(false, "Unable to import issuer account!")
        }

        try! obtain_kin_and_lumens(for: (account0 as! KinStellarAccount).stellarAccount)
        try! obtain_kin_and_lumens(for: (account1 as! KinStellarAccount).stellarAccount)
    }

    override func tearDown() {
        super.tearDown()

        kinClient.deleteKeystore()
    }

    func obtain_kin_and_lumens(for account: StellarAccount) throws {
        let group = DispatchGroup()
        group.enter()

        var e: Error?
        let stellar = Stellar(baseURL: node.url,
                              kinIssuer: "GBOJSMAO3YZ3CQYUJOUWWFV37IFLQVNVKHVRQDEJ4M3O364H5FEGGMBH")

        guard
            let issuer = issuer
            else {
                throw KinError.unknown
        }

        stellar.fund(account: account.publicKey!) { success in
            if !success {
                e = KinError.unknown

                group.leave()

                return
            }

            stellar
                .trustKIN(account: account,
                          passphrase: self.passphrase) { txHash, error in
                            if let error = error {
                                e = error

                                group.leave()

                                return
                            }

                            stellar
                                .payment(source: issuer,
                                         destination: account.publicKey!,
                                         amount: 10000,
                                         passphrase: self.passphrase) { txHash, error in
                                            defer {
                                                group.leave()
                                            }

                                            e = error
                            }
            }
        }

        group.wait()

        if let error = e {
            throw error
        }
    }

    func wait_for_non_zero_balance(account: KinAccount) throws -> Balance {
        var balance = try account.balance()

        let exp = expectation(for: NSPredicate(block: { _, _ in
            do {
                balance = try account.balance()
            }
            catch {
                XCTAssertTrue(false, "Something went wrong: \(error)")
            }

            return balance > 0
        }), evaluatedWith: balance, handler: nil)

        self.wait(for: [exp], timeout: 120)

        return balance
    }

    func test_balance_sync() {
        do {
            var balance = try account0?.balance()

            if balance == 0 {
                balance = try wait_for_non_zero_balance(account: account0!)
            }

            XCTAssertNotEqual(balance, 0)
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }

    }

    func test_balance_async() {
        var balanceChecked: Balance? = nil
        let expectation = self.expectation(description: "wait for callback")

        do {
            _ = try wait_for_non_zero_balance(account: account0!)

            account0?.balance { balance, _ in
                balanceChecked = balance
                expectation.fulfill()
            }

            self.waitForExpectations(timeout: 25.0)

            XCTAssertNotEqual(balanceChecked, 0)
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }

    }

    func test_pending_balance() {
        do {
            let pendingBalance = try account0?.pendingBalance()

            XCTAssertNotNil(pendingBalance,
                            "Unable to retrieve pending balance for account: \(String(describing: account0))")
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_pending_balance_async() {
        let expectation = self.expectation(description: "wait for callback")

        account0!.pendingBalance(completion: { balance, error in
            let bothNil = balance == nil && error == nil
            let bothNotNil = balance != nil && error != nil

            let stringBalance = String(describing: balance)
            let stringError = String(describing: error)

            XCTAssertFalse(bothNil,
                           "Only one of balance [\(stringBalance)] and error [\(stringError)] should be nil")
            XCTAssertFalse(bothNotNil,
                           "Only one of balance [\(stringBalance)] and error [\(stringError)] should be non-nil")

            expectation.fulfill()
        })

        self.waitForExpectations(timeout: 5.0)
    }

    func test_send_transaction() {
        let sendAmount: UInt64 = 5

        do {
            guard
                let account0 = account0,
                let account1 = account1 else {
                    XCTAssertTrue(false, "No accounts to use.")
                    return
            }

            var startBalance0 = try account0.balance()
            let startBalance1 = try account1.balance()

            if startBalance0 == 0 {
                startBalance0 = try wait_for_non_zero_balance(account: account0)
            }

            let txId = try account0.sendTransaction(to: account1.publicAddress,
                                                     kin: sendAmount,
                                                     passphrase: passphrase)

            XCTAssertNotNil(txId)

            let balance0 = try account0.balance()
            let balance1 = try account1.balance()

            XCTAssertEqual(balance0, startBalance0 - Decimal(sendAmount) / Decimal(10000000))
            XCTAssertEqual(balance1, startBalance1 + Decimal(sendAmount) / Decimal(10000000))
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_send_transaction_with_insufficient_funds() {
        do {
            guard
                let account0 = account0,
                let account1 = account1 else {
                    XCTAssertTrue(false, "No accounts to use.")
                    return
            }

            let balance = try account0.balance()

            do {
                _ = try account0.sendTransaction(to: account1.publicAddress,
                                                 kin: (balance * 10000000 as NSDecimalNumber).uint64Value + 1,
                                                 passphrase: passphrase)
                XCTAssertTrue(false,
                              "Tried to send kin with insufficient funds, but didn't get an error")
            }
            catch {
                if let paymentError = error as? PaymentError {
                    XCTAssertEqual(paymentError, PaymentError.PAYMENT_UNDERFUNDED)
                } else {
                    print(error)
                    XCTAssertTrue(false,
                                  "Tried to send kin, and got error, but not a PaymentError: \(error.localizedDescription)")
                }
            }
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_use_after_delete_balance() {
        do {
            let account = kinClient.accounts[0]

            try kinClient.deleteAccount(at: 0, with: passphrase)
            _ = try account?.balance()

            XCTAssert(false, "An exception should have been thrown.")
        }
        catch {
            XCTAssert((error as? KinError) == KinError.accountDeleted, "Expected .accountDeleted error, received: \(error)")
        }
    }

    func test_use_after_delete_pending_balance() {
        do {
            let account = kinClient.accounts[0]

            try kinClient.deleteAccount(at: 0, with: passphrase)
            _ = try account?.pendingBalance()

            XCTAssert(false, "An exception should have been thrown.")
        }
        catch {
            XCTAssert((error as? KinError) == KinError.accountDeleted, "Expected .accountDeleted error, received: \(error)")
        }
    }

    func test_use_after_delete_transaction() {
        do {
            let account = kinClient.accounts[0]

            try kinClient.deleteAccount(at: 0, with: passphrase)
            _ = try account?.sendTransaction(to: "", kin: 1, passphrase: passphrase)

            XCTAssert(false, "An exception should have been thrown.")
        }
        catch {
            XCTAssert((error as? KinError) == KinError.accountDeleted, "Expected .accountDeleted error, received: \(error)")
        }
    }

    func test_keystore_export() {
        do {
            let account = try kinClient.addAccount(with: passphrase)
            let keyStore = try account.exportKeyStore(passphrase: passphrase, exportPassphrase: "exportPass")

            XCTAssertNotNil(keyStore, "Unable to retrieve keyStore account: \(String(describing: account))")
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }
}
