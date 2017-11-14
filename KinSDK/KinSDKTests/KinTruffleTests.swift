//
//  KinTruffleTests.swift
//  KinSDKTests
//
//  Created by Elazar Yifrach on 08/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinSDK
import Geth

class KinTruffleTests: XCTestCase {

    var kinClient: KinClient!
    let passphrase = UUID().uuidString
    let truffle = NodeProvider(networkId: NetworkIdTruffle)

    override func setUp() {
        super.setUp()
        let accountStore = KinAccountStore(url: truffle.url, networkId: truffle.networkId)
        try? accountStore.deleteKeystore()
        kinClient = try! KinClient(provider: truffle)
    }

    override func tearDown() {
        let accountStore = KinAccountStore(url: truffle.url, networkId: truffle.networkId)
        try? accountStore.deleteKeystore()
        super.tearDown()
    }

    func test_create_account_from_private_key() {

        do {
            if  let key = TestsConfiguration.config?["ACCOUNT_0_PRIVATE_KEY"] as? String,
                let account = try kinClient.createAccountIfNeeded(with: key, passphrase: passphrase) {

                print("created account \(account.publicAddress)")
                XCTAssertNotNil(account)
                if let balance = try? account.balance() {
                    XCTAssertEqual((balance as NSDecimalNumber).uint64Value, 1000)
                } else {
                    XCTAssertTrue(false, "Couldn't get balance")
                }

            } else {
                XCTAssertTrue(false, "Test rpc did not set up properly. check the build phases for testing")
            }
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }
}
