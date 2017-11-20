//
//  KinAccountTests.swift
//  KinTestHostTests
//
//  Created by Avi Shevin on 02/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinSDK
import Geth

class KinAccountTests: XCTestCase {

    var kinClient: KinClient!
    let passphrase = UUID().uuidString
    let truffle = NodeProvider(networkId: NetworkIdTruffle)

    override func setUp() {
        super.setUp()

        kinClient = try! KinClient(provider: truffle)
    }

    override func tearDown() {
        super.tearDown()

        kinClient.deleteKeystore()
    }

    func test_publicAddress() {
        let expectedPublicAddress = "0x8B455Ab06C6F7ffaD9fDbA11776E2115f1DE14BD"

        do {
            let key = TruffleConfiguration.privateKey(at: 0)
            let account = try kinClient.createAccount(with: key, passphrase: passphrase)

            let publicAddress = account?.publicAddress

            XCTAssertEqual(publicAddress, expectedPublicAddress)
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }
    
    func test_balance_sync() {
        do {
            let key = TruffleConfiguration.privateKey(at: 0)
            let account = try kinClient.createAccount(with: key, passphrase: passphrase)

            let balance = try account?.balance()

            XCTAssertEqual(balance, TruffleConfiguration.STARTING_BALANCE)
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
        
    }
    
    func test_balance_async() {
        var account: KinAccount? = nil
        do {
            let key = TruffleConfiguration.privateKey(at: 0)
            account = try kinClient.createAccount(with: key, passphrase: passphrase)
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
        
        var balanceChecked: Balance? = nil
        let expectation = self.expectation(description: "wait for callback")
        account?.balance { balance, error in
            balanceChecked = balance
            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5.0)
        XCTAssertEqual(balanceChecked, TruffleConfiguration.STARTING_BALANCE)
    }

    func test_pending_balance() {
        do {
            let account = try kinClient.createAccountIfNeeded(with: passphrase)
            let pendingBalance = try account?.pendingBalance()

            XCTAssertNotNil(pendingBalance, "Unable to retrieve pending balance for account: \(String(describing: account))")
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_pending_balance_async() {
        let expectation = self.expectation(description: "wait for callback")

        do {
            let account = try kinClient.createAccountIfNeeded(with: passphrase)

            account?.pendingBalance(completion: { balance, error in
                let bothNil = balance == nil && error == nil
                let bothNotNil = balance != nil && error != nil

                let stringBalance = String(describing: balance)
                let stringError = String(describing: error)

                XCTAssertFalse(bothNil, "Only one of balance [\(stringBalance)] and error [\(stringError)] should be nil")
                XCTAssertFalse(bothNotNil, "Only one of balance [\(stringBalance)] and error [\(stringError)] should be non-nil")

                expectation.fulfill()
            })
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")

            expectation.fulfill()
        }

        self.waitForExpectations(timeout: 5.0)
    }

    func test_send_transaction() {
        let sendAmount: UInt64 = 5

        let key0 = TruffleConfiguration.privateKey(at: 0)
        let key1 = TruffleConfiguration.privateKey(at: 1)

        do {
            guard
                let account0 = try kinClient.createAccount(with: key0, passphrase: passphrase),
                let account1 = try kinClient.createAccount(with: key1, passphrase: passphrase) else {
                    XCTAssertTrue(false, "account creation failed")
                    return
            }

            let startBalance0 = try account0.balance()
            let startBalance1 = try account1.balance()

            let txId = try account0.sendTransaction(to: account1.publicAddress,
                                                     kin: sendAmount,
                                                     passphrase: passphrase)

            XCTAssertNotNil(txId)

            let balance0 = try account0.balance()
            let balance1 = try account1.balance()

            XCTAssertEqual(balance0, startBalance0 - Decimal(sendAmount))
            XCTAssertEqual(balance1, startBalance1 + Decimal(sendAmount))
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

//    func test_decimals() {
//        do {
//            let account = try kinClient.createAccountIfNeeded(with: passphrase)
//            let decimals = try account?.decimals()
//
//            XCTAssertNotNil(decimals, "Unable to retrieve decimals for account: \(String(describing: account))")
//        }
//        catch {
//            XCTAssertTrue(false, "Something went wrong: \(error)")
//        }
//    }
}
