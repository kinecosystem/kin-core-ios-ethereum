//
//  Contract.swift
//  KinSDK
//
//  Created by Elazar Yifrach on 04/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//
import Geth

enum ContractError: Error {
    case geth
    case setup
}

class Contract {
    
    fileprivate var boundContract: GethBoundContract?
    fileprivate weak var context: GethContext?
    fileprivate weak var client: GethEthereumClient?
    fileprivate let contractAddress = GethNewAddressFromHex("0xef2fcc998847db203dea15fc49d0872c7614910c", nil)
    
    init(with context: GethContext, client: GethEthereumClient) {
        self.context = context
        self.client = client
        bindContractAbi()
    }
    
    func bindContractAbi() {
        do {
            if let path = Bundle(for: Contract.self).path(forResource: "contractABI", ofType: "json") {
                let abi = try String(contentsOfFile: path, encoding: .utf8)
                boundContract = GethBindContract(contractAddress, abi, client, nil)
            }
        } catch {
            fatalError("Unable to load contract abi: \(error)")
        }
    }
    
    func call(method: String, inputs: [GethInterface] = [], outputs: [GethInterface]) throws {

        guard   let context = context,
                let client = client,
                let opts = GethNewCallOpts() else { throw ContractError.setup }
        
        let price = try client.suggestGasPrice(context).getInt64()
        
        opts.setContext(context)
        opts.setGasLimit(price)
        
        let args = GethNewInterfaces(inputs.count)!
        let outs = GethNewInterfaces(outputs.count)!
        
        for (i, input) in inputs.enumerated() {
            try args.set(i, object: input)
        }
        for (i, output) in outputs.enumerated() {
            try outs.set(i, object: output)
        }
        
        try boundContract?.call(opts, out_: outs, method: method, args: args)
        
    }
    
}
