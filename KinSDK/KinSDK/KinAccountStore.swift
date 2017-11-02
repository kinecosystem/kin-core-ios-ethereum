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
    
    // Temporary, client with leonid's api keys
    private var _client: GethEthereumClient? = nil
    var client: GethEthereumClient {
        let c = _client ?? {
            let c: GethEthereumClient
            switch networkId {
            case 1:
                c = GethNewEthereumClient("https://mainnet.infura.io/ciS27F9JQYk8MaJd8Fbu", nil)
            case 3:
                c = GethNewEthereumClient("https://ropsten.infura.io/ciS27F9JQYk8MaJd8Fbu", nil)
            default:
                c = GethNewEthereumClient("https://mainnet.infura.io/ciS27F9JQYk8MaJd8Fbu", nil)
            }

            _client = c

            return c
        }()

        return c
    }

    
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

    func createTransactionETH(from account: GethAccount, amount: Int64, to: GethAddress) -> GethTransaction? {
        guard keystore.hasAddress(account.getAddress()) else { return nil }
        let nonce: UnsafeMutablePointer<Int64> = UnsafeMutablePointer<Int64>.allocate(capacity: 1)
        defer {
            _ = UnsafeMutablePointer<Int64>.deallocate(nonce)
        }
        if (try? client.getPendingNonce(at: context,
                                             account: account.getAddress(),
                                             nonce: nonce)) != nil {
            let gasPrice = try! client.suggestGasPrice(context)
            return GethNewTransaction(nonce.pointee, to, GethNewBigInt(amount), gasPrice, gasPrice, nil)
        }
        return nil
    }
    
    func signTransactionETH(from account:GethAccount, transaction: GethTransaction, passphrase: String) -> GethTransaction? {
        return try? keystore.signTxPassphrase(account, passphrase: passphrase, tx: transaction, chainID: GethNewBigInt(networkId))
    }
    
    //func getBalance(address: GethAddress, )
    
    
}
