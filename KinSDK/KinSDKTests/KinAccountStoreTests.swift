//
//  KinAccountStoreTests.swift
//  KinWalletTests
//
//  Created by Kin Foundation
//  Copyright © 2017 Kik Interactive. All rights reserved.
//

import XCTest
import KinSDKPrivate
@testable import KinSDK

let ropsten = NodeProvider(networkId: NetworkIdRopsten)

// todo add to readme https://github.com/ethereum/go-ethereum/issues/14369#issuecomment-318823725
class KinAccountStoreTests: XCTestCase {
    let store = KinAccountStore(url: ropsten.url, networkId: ropsten.networkId)
    let creationPass = UUID().uuidString
    let exportPass = UUID().uuidString
    var account: GethAccount!

    override func setUp() {
        super.setUp()

        do {
            account = try store.createAccount(passphrase: creationPass)
        } catch {
            XCTAssert(false, "Couldn't create account from store.createAccount()")
        }
    }

    override func tearDown() {
        super.tearDown()

        let accountStore = KinAccountStore(url: ropsten.url,
                                           networkId: ropsten.networkId)
        try? accountStore.deleteKeystore()
    }

    func test_key_store_created() {
        XCTAssertNotNil(store)
    }

    func test_create_account() {
        XCTAssertTrue(account.isKind(of: GethAccount.self))
    }

    func test_delete_with_bad_password_fails() {
        do {
            try store.delete(account: account, passphrase: "HiImWrongPass")
            XCTAssertTrue(false, "A delete should fail if using worng password")
        } catch {
            XCTAssertTrue(true, "A delete should fail if using worng password")
        }
    }

    func test_update_account() {
        let newPass = UUID().uuidString
        var result = store.update(account: account, passphrase: creationPass,
                                  newPassphrase: newPass)
        XCTAssertTrue(result, "Failed updating account with creation password")
        result = store.update(account: account, passphrase: creationPass,
                              newPassphrase: newPass)
        XCTAssertFalse(result, "Account should not be able to open with old password")
        result = store.update(account: account, passphrase: newPass,
                              newPassphrase: "nevermind")
        XCTAssertTrue(result, "Account should have been accessible with new password")
        // just letting teardown delete this account
        _ = store.update(account: account, passphrase: "nevermind",
                         newPassphrase: creationPass)
    }

    func test_export_delete_and_import_account() {
        let numberOfStores = store.accounts.size()
        XCTAssertTrue(numberOfStores > 0, "Number of files at test's start should be at least 1, Check setup func.")
        let data = try? store.export(account: account,
                                     passphrase: creationPass,
                                     exportPassphrase: creationPass)
        XCTAssertTrue(data != nil, "Account failed to export")

        do {
            try store.delete(account: account, passphrase: creationPass)

            XCTAssertTrue(store.accounts.size() == numberOfStores - 1)
            _ = store.importAccount(keystoreData: data!, passphrase: creationPass,
                                    newPassphrase: creationPass)
            XCTAssertTrue(store.accounts.size() == numberOfStores)
        } catch {
            XCTAssertTrue(false, "Unable to delete account: \(error)")
        }
    }
}
