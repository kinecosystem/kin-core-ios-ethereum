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
    let provider = InfuraTestProvider(apiKey: "ciS27F9JQYk8MaJd8Fbu")

    override func setUp() {
        super.setUp()

        kinClient = try! KinClient(provider: provider)
    }

    override func tearDown() {
        super.tearDown()

        let accountStore = KinAccountStore(url: provider.url, networkId: provider.networkId)
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
        
        var account:KinAccount!
        do {
            account = try kinClient.createAccountIfNeeded(with: passphrase)
            let balance = try account?.balance()
            XCTAssertNotNil(balance, "Unable to retrieve balance for account: \(String(describing: account))")
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
        
    }
    
    func test_balance_async() {
        
        var account:KinAccount!
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
        XCTAssertNil(balanceChecked, "Operation did not perform async")
        self.waitForExpectations(timeout: 5.0)
        XCTAssertNotNil(balanceChecked, "Unable to retrieve balance for account: \(String(describing: account))")
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
