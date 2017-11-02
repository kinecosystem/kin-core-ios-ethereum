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

        kinClient = KinClient(provider: provider)
    }

    override func tearDown() {
        super.tearDown()

        let accountStore = KinAccountStore(url: provider.url, networkId: provider.networkId)
        try? accountStore.deleteKeystore()
    }

    func test_private_key_export() {
        do {
            let account = try kinClient.createAccountIfNecessary(with: passphrase)
            let privateKey = try account?.privateKey(with: passphrase)

            XCTAssertNotNil(privateKey, "Unable to retrieve private key for account: \(String(describing: account))")
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }
}
