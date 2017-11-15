//
//  KinTestHostTests.swift
//  KinTestHostTests
//
//  Created by Avi Shevin on 01/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinTestHost
@testable import KinSDK

class KinClientTests: XCTestCase {
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

    func test_account_creation() {
        var e: Error? = nil
        var account: KinAccount? = nil

        do {
            account = try kinClient.createAccountIfNeeded(with: passphrase)
        }
        catch {
            e = error
        }

        XCTAssertNotNil(account, "Creation failed: \(String(describing: e))")
    }

    func test_account_creation_limited_to_one() {
        do {
            _ = try kinClient.createAccountIfNeeded(with: passphrase)
            _ = try kinClient.createAccountIfNeeded(with: passphrase)
        }
        catch {
        }

        let accountStore = KinAccountStore(url: ropsten.url, networkId: ropsten.networkId)
        let accountCount = accountStore.accounts.size()

        XCTAssertEqual(accountCount, 1)
    }

    func test_keystore_export() {
        do {
            let account = try kinClient.createAccountIfNeeded(with: passphrase)
            let keyStore = try kinClient.exportKeyStore(passphrase: passphrase, exportPassphrase: "exportPass")

            XCTAssertNotNil(keyStore, "Unable to retrieve keyStore account: \(String(describing: account))")
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }
}
