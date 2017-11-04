//
//  KinAccountStore.swift
//  KinWallet
//
//  Created by Elazar Yifrach on 18/10/2017.
//  Copyright © 2017 Kik Interactive. All rights reserved.
//

import Foundation
import Geth

class KinAccountStore {
    
    struct Directories {
        static let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                   .userDomainMask,
                                                                   true).first!
        static let networks = "networks"
        static let keystore = "keystore"
        static let account = "account"
    }
    
    enum EthereumNetworkId: Int64, CustomStringConvertible {
        
        case main = 1       // Ethereum public main network
        case ropsten = 3    // Ethereum test network
        
        var description: String {
            switch self {
            case .main:
                return "main"
            case .ropsten:
                return "ropsten"
            }
        }
        
    }
    
    lazy var client: GethEthereumClient = {
        return GethNewEthereumClient(self.serviceUrl.path, nil)
    }()

    
    fileprivate let keystore: GethKeyStore!
    let context = GethNewContext()
    
    var accounts: GethAccounts {
        get {
            return keystore.getAccounts()
        }
    }
    fileprivate let networkId: Int64
    fileprivate let serviceUrl: URL

    fileprivate var dataDir: String {
        return [
            Directories.documents,
            Directories.networks,
            networkId.description,
            Directories.keystore,
            ]
            .joined(separator: "/")
    }

    init(url: URL, networkId: Int64) {
        self.serviceUrl = url
        self.networkId = networkId

        let dataDir = [
            Directories.documents,
            Directories.networks,
            networkId.description,
            Directories.keystore,
            ]
            .joined(separator: "/")

        keystore = GethNewKeyStore(dataDir, GethLightScryptN, GethLightScryptP)
    }
    
    func createAccount(passphrase: String) throws -> GethAccount {
        return try keystore.newAccount(passphrase)
    }
    
    func importAccount(keystoreData:Data, passphrase: String,
                       newPassphrase: String) -> GethAccount? {
        return try? keystore.importKey(keystoreData, passphrase: passphrase,
                                       newPassphrase: newPassphrase)
    }
    
    func export(account: GethAccount, passphrase: String,
                        exportPassphrase: String) throws -> Data {
        return try keystore.exportKey(account, passphrase: passphrase,
                                      newPassphrase: exportPassphrase)
    }
    
    func update(account: GethAccount, passphrase: String,
                       newPassphrase: String) -> Bool {
        return (try? keystore.update(account, passphrase: passphrase,
                                     newPassphrase: newPassphrase)) != nil
    }
    
    func delete(account: GethAccount, passphrase: String) throws {
        try keystore.delete(account, passphrase: passphrase)
    }
    
    func deleteKeystore() throws {
        try FileManager.default.removeItem(at: URL(fileURLWithPath: dataDir))
    }
    
    
}
