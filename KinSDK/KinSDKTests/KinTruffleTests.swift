//
//  KinTruffleTests.swift
//  KinSDKTests
//
//  Created by Elazar Yifrach on 08/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import XCTest
@testable import KinSDK

class KinTruffleTests: XCTestCase {

    var kinClient: KinClient!
    let passphrase = UUID().uuidString
    let truffle = NodeProvider(networkId: NetworkIdTruffle)

    override func setUp() {
        super.setUp()
        kinClient = try! KinClient(provider: truffle)
    }

    override func tearDown() {
        kinClient.deleteKeystore()

        super.tearDown()
    }

    func test_create_account_from_private_key() {
        do {
            let key = TruffleConfiguration.privateKey(at: 0)
            if let account = try kinClient.createAccount(with: key, passphrase: passphrase) {
                print("created account \(account.publicAddress)")

                XCTAssertNotNil(account)

                do {
                    let balance = try account.balance()
                    XCTAssertEqual(balance, TruffleConfiguration.STARTING_BALANCE)
                }
                catch {
                    XCTAssertTrue(false, "Couldn't get balance: \(error)")
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
