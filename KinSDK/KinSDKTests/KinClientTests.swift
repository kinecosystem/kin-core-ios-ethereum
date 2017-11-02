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
    let provider = InfuraTestProvider(apiKey: "ciS27F9JQYk8MaJd8Fbu")

    override func setUp() {
        super.setUp()

        kinClient = KinClient(provider: provider)
    }
    
    override func tearDown() {
        super.tearDown()

        let accountStore = KinAccountStore(url: provider.url, networkId: provider.networkId)
        try? accountStore.deleteKeystore()
    }
    
    func test_account_creation() {
        var e: Error? = nil
        var account: KinAccount? = nil

        do {
            account = try kinClient.createAccountIfNecessary(with: passphrase)
        }
        catch {
            e = error
        }

        XCTAssertNotNil(account, "Creation failed: \(String(describing: e))")
    }

    func test_account_creation_limited_to_one() {
        do {
            _ = try kinClient.createAccountIfNecessary(with: passphrase)
            _ = try kinClient.createAccountIfNecessary(with: passphrase)
        }
        catch {
        }

        let accountStore = KinAccountStore(url: provider.url, networkId: provider.networkId)
        let accountCount = accountStore.accounts.size()

        XCTAssertEqual(accountCount, 1)
    }
}
