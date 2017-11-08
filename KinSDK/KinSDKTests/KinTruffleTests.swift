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
        //kinClient = try! KinClient(provider: provider)
    }
    
    override func tearDown() {
//        let accountStore = KinAccountStore(url: truffle.url, networkId: truffle.networkId)
//        try? accountStore.deleteKeystore()
        super.tearDown()
    }
    /*
    func test_create_account_from_private_key() {
        do {
            if let key = ProcessInfo.processInfo.environment["wallet_a_private_key"] {
                let account = try kinClient.createAccountIfNecessary(with: key, passphrase: passphrase)
            } else {
                fatalError("Test rpc did not set up properly. check the build phases for testing")
            }
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }
     */
}
