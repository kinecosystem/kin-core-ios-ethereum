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
    var accountStore: KinAccountStore!
    lazy var configuration: [String: Any] = {
        guard let fileUrl = Bundle.main.url(forResource: "testConfig", withExtension: "plist"),
            let data = try? Data(contentsOf: fileUrl),
            let configDict = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: Any]  else {
                fatalError("Seems like you are trying to run tests on the local network, but " +
                    "the tests environment isn't correctly set up. Please see readme for more details")
        }
        return configDict
    }()
    
    override func setUp() {
        super.setUp()
        accountStore = KinAccountStore(url: truffle.url, networkId: truffle.networkId)
        kinClient = try! KinClient(provider: truffle)
    }

    override func tearDown() {
        try? accountStore.deleteKeystore()
        accountStore = nil
        super.tearDown()
    }

    func test_create_account_from_private_key() {

        do {
            if  let key = configuration["ACCOUNT_0_PRIVATE_KEY"] as? String,
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
