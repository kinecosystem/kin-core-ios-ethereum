//
//  Contract.swift
//  KinSDK
//
//  Created by Elazar Yifrach on 04/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

enum ContractError: Error {
    case geth
    case internalInconsistancy
}

class Contract {
    
    fileprivate var boundContract: GethBoundContract?
    fileprivate weak var context: GethContext?
    fileprivate weak var client: GethEthereumClient?
    fileprivate let contractAddress: GethAddress
    static let defaultGasLimit: Int64 = 4300000
    
    init(with context: GethContext, networkId: UInt64, client: GethEthereumClient) {
        self.context = context
        self.client = client
        var address: String
        switch networkId {
        case NetworkIdMain:
            address = "0x818fc6c2ec5986bc6e2cbf00939d90556ab12ce5"
        default:
            address = "0xef2fcc998847db203dea15fc49d0872c7614910c"
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
        } catch {
            fatalError("Unable to load contract abi: \(error)")
        }
    }
    
    func call(method: String, inputs: [GethInterface] = [],
              outputs: [GethInterface]) throws {
        
        guard   let context = context,
                let options = GethNewCallOpts(),
                let contract = boundContract else {
                throw ContractError.internalInconsistancy
        }
        
        options.setContext(context)
        
        try contract.call(options, out_: try outputs.interfaces(),
                                method: method,
                                args: try inputs.interfaces())
        
    }
    
    func transact(method: String, options:GethTransactOpts,
                  parameters: [GethInterface]) throws -> GethTransaction {
        guard let contract = boundContract else {
            throw ContractError.internalInconsistancy
        }
        return try contract.transact(options, method: method,
                                    args: try parameters.interfaces())
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
