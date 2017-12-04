//
//  KinTestHostTests.swift
//  KinTestHostTests
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinTestHost
@testable import KinSDK

class KinClientTests: XCTestCase {
    var kinClient: KinClient!
    let passphrase = UUID().uuidString
    let truffle = NodeProvider(networkId: .truffle)

    override func setUp() {
        super.setUp()

        do {
            kinClient = try KinClient(provider: truffle)
        }
        catch {
            XCTAssert(false, "Couldn't create kinClient")
        }
    }

    override func tearDown() {
        super.tearDown()

        try? kinClient.deleteKeystore()
    }

    func test_account_creation() {
        var e: Error? = nil
        var account: KinAccount? = nil

        XCTAssertNil(account, "There should not be an existing account!")

        do {
            account = try kinClient.createAccount(with: passphrase)
        }
        catch {
            e = error
        }

        XCTAssertNotNil(account, "Creation failed: \(String(describing: e))")
    }

    func test_delete_account() {
        do {
            let account = try kinClient.createAccount(with: passphrase)

            try kinClient.deleteAccount(at: 0, with: passphrase)

            XCTAssertNotNil(account)
            XCTAssertNil(kinClient.accounts[0])
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    func test_account_instance_reuse() {
        do {
            let _ = try kinClient.createAccount(with: passphrase) as? KinEthereumAccount

            let first = kinClient.accounts[0] as? KinEthereumAccount
            let second = kinClient.accounts[0] as? KinEthereumAccount

            XCTAssertNotNil(second)
            XCTAssert(first === second!)
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }

    @available(*, deprecated)
    func test_account_creation_limited_to_one_deprecated() {
        do {
            _ = try kinClient.createAccountIfNeeded(with: passphrase)
            _ = try kinClient.createAccountIfNeeded(with: passphrase)
        }
        catch {
        }

        let accountStore = KinAccountStore(url: truffle.url, networkId: truffle.networkId)
        let accountCount = accountStore.accounts.size()

        XCTAssertEqual(accountCount, 1)
    }

    @available(*, deprecated)
    func test_delete_account_deprecated() {
        do {
            let account = try kinClient.createAccount(with: passphrase)

            try kinClient.deleteAccount(with: passphrase)

            XCTAssertNotNil(account)
            XCTAssertNil(kinClient.account)
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }
}
