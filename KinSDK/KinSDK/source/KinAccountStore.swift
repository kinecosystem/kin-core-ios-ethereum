//
//  KinAccountStore.swift
//  KinWallet
//
//  Created by Kin Foundation
//  Copyright © 2017 Kik Interactive. All rights reserved.
//

import Foundation
import KinSDKPrivate

final class KinAccountStore {
    struct Directories {
        static let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                   .userDomainMask,
                                                                   true).first!
        static let networks = "networks"
        static let keystore = "keystore"
        static let account = "account"
    }

    let client: GethEthereumClient

    let keystore: GethKeyStore!
    let context = GethNewContext()!

    var accounts: GethAccounts {
        return keystore.getAccounts()
    }
    let networkId: NetworkId

    fileprivate var dataDir: String {
        return [
            Directories.documents,
            Directories.networks,
            networkId.description,
            Directories.keystore
            ]
            .joined(separator: "/")
    }

    init(url: URL, networkId: NetworkId) {
        self.networkId = networkId

        let dataDir = [
            Directories.documents,
            Directories.networks,
            networkId.description,
            Directories.keystore
            ]
            .joined(separator: "/")

        keystore = GethNewKeyStore(dataDir, GethLightScryptN, GethLightScryptP)
        self.client = GethNewEthereumClient(url.absoluteString, nil)
    }

    func createAccount(passphrase: String) throws -> GethAccount {
        return try keystore.newAccount(passphrase)
    }

    func importAccount(keystoreData: Data, passphrase: String,
                       newPassphrase: String) -> GethAccount? {
        return try? keystore.importKey(keystoreData, passphrase: passphrase,
                                       newPassphrase: newPassphrase)
    }

    func importAccount(with privateKey: String, passphrase: String) -> GethAccount? {
        return try? keystore.importECDSAKey(privateKey.hexaBytes.data,
                                            passphrase: passphrase)
    }

    func export(account: GethAccount, passphrase: String, exportPassphrase: String) throws -> Data {
        return try keystore.exportKey(account, passphrase: passphrase,
                                      newPassphrase: exportPassphrase)
    }

    func update(account: GethAccount, passphrase: String, newPassphrase: String) -> Bool {
        return (try? keystore.update(account, passphrase: passphrase,
                                     newPassphrase: newPassphrase)) != nil
    }

    func delete(account: GethAccount, passphrase: String) throws {
        try keystore.delete(account, passphrase: passphrase)
    }

    func deleteKeystore() throws {
        try FileManager.default.removeItem(at: URL(fileURLWithPath: dataDir))
    }

    func transactionReceipt(for transactionId: TransactionId) throws -> GethReceipt {
        var error: NSError? = nil
        let hash = GethNewHashFromHex(transactionId, &error)

        if let error = error {
            throw error
        }

        return try client.getTransactionReceipt(context, hash: hash)
    }
}
