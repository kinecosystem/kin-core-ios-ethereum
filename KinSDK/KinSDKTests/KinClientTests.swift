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

        kinClient = try! KinClient(provider: provider)
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

        let accountStore = KinAccountStore(url: provider.url, networkId: provider.networkId)
        let accountCount = accountStore.accounts.size()

        XCTAssertEqual(accountCount, 1)
    }

    func test_keystore_export() {
        do {
            let account = try kinClient.createAccountIfNeeded(with: passphrase)
            let privateKey = try kinClient.keyStore(with: passphrase)

            XCTAssertNotNil(privateKey, "Unable to retrieve private key for account: \(String(describing: account))")
        }
        catch {
            XCTAssertTrue(false, "Something went wrong: \(error)")
        }
    }
    
    func test_kinToken() {

        let kin100FromDouble = KinToken(value: 100)
        let bigIntShortString = GethNewBigInt(0)!
        bigIntShortString.setString("100", base: 10)
        let bigIntLongString = GethNewBigInt(0)!
        bigIntLongString.setString("100000000000000000000", base: 10)
        let bigIntLongStringReminder = GethNewBigInt(0)!
        bigIntLongStringReminder.setString("100000000000000000001", base: 10)

        guard let kin100FromUnder18CharsString = try? KinToken(string: "100") else {
            XCTAssertTrue(false, "Kin could not be created from short string")
            return
        }
        guard   let kin100FromOver18CharsString = try? KinToken(string: "100000000000000000000"),
                let kin100FromOver18CharsStringWithReminder = try? KinToken(string: "100000000000000000001") else {
            XCTAssertTrue(false, "Kin could not be created from long string")
            return
        }
        guard   let KinFromBigIntWithInt = try? KinToken(bigInt: GethNewBigInt(100)),
                let KinFromBigIntWithShortString = try? KinToken(bigInt: bigIntShortString),
                let KinFromBigIntWithLongString = try? KinToken(bigInt: bigIntLongString),
                let KinFromBigIntWithLongStringRemoinder = try? KinToken(bigInt: bigIntLongStringReminder) else {
            XCTAssertTrue(false, "Kin could not be created from GethBigInt")
            return
        }

        XCTAssertTrue((kin100FromUnder18CharsString.value as NSDecimalNumber).uint64Value == 100)
        XCTAssertEqual(kin100FromUnder18CharsString.value, kin100FromOver18CharsString.value)
        XCTAssertEqual(kin100FromDouble.value, kin100FromOver18CharsString.value)
        XCTAssertTrue(String(describing: kin100FromOver18CharsString.value) == "100")
        XCTAssertTrue(String(describing: kin100FromOver18CharsStringWithReminder.value) == "100.000000000000000001")
        XCTAssertTrue(String(describing: KinFromBigIntWithLongStringRemoinder.value) == "100.000000000000000001")
        XCTAssertNotEqual(kin100FromOver18CharsStringWithReminder.value, kin100FromOver18CharsString.value)
        XCTAssertEqual(kin100FromDouble.value, KinFromBigIntWithLongString.value)
        XCTAssertEqual(kin100FromDouble.value, KinFromBigIntWithShortString.value)
        XCTAssertEqual(kin100FromDouble.value, KinFromBigIntWithInt.value)

    }
}
