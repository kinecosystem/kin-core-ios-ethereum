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
    let ropsten = NodeProvider(networkId: NetworkIdRopsten)

    override func setUp() {
        super.setUp()

        kinClient = try! KinClient(provider: ropsten)
    }

    override func tearDown() {
        super.tearDown()

        let accountStore = KinAccountStore(url: ropsten.url, networkId: ropsten.networkId)
        try? accountStore.deleteKeystore()
    }

    func test_publicAddress() {
        do {
            let account = try kinClient.createAccountIfNeeded(with: passphrase)
            let publicAddress = account?.publicAddress

            XCTAssertNotNil(publicAddress, "Unable to retrieve public address for account: \(String(describing: account))")
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }
    
    func test_balance_sync() {
        do {
            let account = try kinClient.createAccountIfNeeded(with: passphrase)
            let balance = try account?.balance()
            XCTAssertNotNil(balance, "Unable to retrieve balance for account: \(String(describing: account))")
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
        
    }
    
    func test_balance_async() {
        var account: KinAccount? = nil
        do {
            account = try kinClient.createAccountIfNeeded(with: passphrase)
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
        XCTAssertNotNil(balanceChecked, "Unable to retrieve balance for account: \(String(describing: account))")
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

    func test_decimals() {
        do {
            let account = try kinClient.createAccountIfNeeded(with: passphrase)
            let decimals = try account?.decimals()
            
            XCTAssertNotNil(decimals, "Unable to retrieve decimals for account: \(String(describing: account))")
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }
}
