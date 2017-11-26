//
//  Contract.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//
import KinSDKPrivate

enum ContractError: Error {
    case geth
    case internalInconsistency
}

final class Contract {
    private struct Constants {
        static let sha3Transfer = "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"
    }

    fileprivate var boundContract: GethBoundContract?
    fileprivate weak var context: GethContext?
    fileprivate weak var client: GethEthereumClient?
    fileprivate let contractAddress: GethAddress
    static let defaultGasLimit: Int64 = 60000

    init(with context: GethContext, networkId: NetworkId, client: GethEthereumClient) {
        self.context = context
        self.client = client
        var address: String

        switch networkId {
        case .mainNet:
            address = "0x818fc6c2ec5986bc6e2cbf00939d90556ab12ce5"
        case .ropsten:
            address = "0xef2fcc998847db203dea15fc49d0872c7614910c"
        case .truffle:
            guard
                let fileUrl = Bundle.main.url(forResource: "testConfig", withExtension: "plist"),
                let data = try? Data(contentsOf: fileUrl),
                let configDict = try? PropertyListSerialization.propertyList(from: data,
                                                                             options: [],
                                                                             format: nil) as? [String: Any],
                let contractAddress = configDict?["TOKEN_CONTRACT_ADDRESS"] as? String,
                contractAddress.isEmpty == false else {
                    fatalError("Seems like you are trying to run tests on the local network, but " +
                        "the tests environment isn't correctly set up. Please see readme for more details")
            }
            address = contractAddress
        default:
            address = "0xef2fcc998847db203dea15fc49d0872c7614910c"
        }

        guard address.isEmpty == false else {
            fatalError("No address found!")
        }

        self.contractAddress = GethNewAddressFromHex(address, nil)
        bindContractAbi()
    }

    func bindContractAbi() {
        do {
            if let path = Bundle(for: Contract.self).path(forResource: "contractABI",
                                                          ofType: "json") {
                let abi = try String(contentsOfFile: path, encoding: .utf8)
                boundContract = GethBindContract(contractAddress, abi, client, nil)
            }
        }
        catch {
            fatalError("Unable to load contract abi: \(error)")
        }
    }

    func call(method: String, inputs: [GethInterface] = [],
              outputs: [GethInterface]) throws {

        guard   let context = context,
                let options = GethNewCallOpts(),
                let contract = boundContract else {
                throw ContractError.internalInconsistency
        }

        options.setContext(context)

        try contract.call(options, out_: try outputs.interfaces(),
                                method: method,
                                args: try inputs.interfaces())

    }

    func transact(method: String, options: GethTransactOpts,
                  parameters: [GethInterface]) throws -> GethTransaction {
        guard let contract = boundContract else {
            throw ContractError.internalInconsistency
        }
        return try contract.transact(options, method: method,
                                    args: try parameters.interfaces())
    }

    func pendingTransactionLogs(from: String?, to recipient: String?) throws -> GethLogs {
        guard
            let client = client,
            let context = context else {
                throw ContractError.internalInconsistency
        }

        guard
            let query = GethNewFilterQuery(),
            let addresses = GethNewAddressesEmpty(),
            let topics = GethNewTopicsEmpty() else {
                throw ContractError.geth
        }

        addresses.append(contractAddress)
        query.setAddresses(addresses)
        query.setFromBlock(GethBigInt(Int64(GethLatestBlockNumber)))
        query.setToBlock(GethBigInt(Int64(GethPendingBlockNumber)))

        var error: NSError? = nil
        let hash = GethNewHashFromHex(Constants.sha3Transfer, &error)

        if error != nil {
            throw ContractError.geth
        }

        if let hashes = GethNewHashesEmpty() {
            hashes.append(hash)
            topics.append(hashes)
        } else {
            throw ContractError.geth
        }

        if let hashes = GethNewHashesEmpty() {
            if let from = from {
                hashes.append(try hexAddressToTopicHash(address: from))
            }

            topics.append(hashes)
        } else {
            throw ContractError.geth
        }

        if let hashes = GethNewHashesEmpty() {
            if let recipient = recipient {
                hashes.append(try hexAddressToTopicHash(address: recipient))
            }

            topics.append(hashes)
        } else {
            throw ContractError.geth
        }

        query.setTopics(topics)

        return try client.filterLogs(context, query: query)
    }

    fileprivate func hexAddressToTopicHash(address: String) throws -> GethHash {
        let topicAddress = "0x000000000000000000000000" + address.suffix(address.count - 2)

        var error: NSError? = nil
        let hash = GethNewHashFromHex(topicAddress, &error)

        if error != nil {
            throw ContractError.geth
        }

        return hash!
    }
}

extension Array where Element == GethInterface {
    func interfaces() throws -> GethInterfaces {
        guard let interfaces = GethNewInterfaces(self.count) else {
            throw KinError.invalidInput
        }
        for (i, object) in self.enumerated() {
            try interfaces.set(i, object: object)
        }
        return interfaces
    }
}
