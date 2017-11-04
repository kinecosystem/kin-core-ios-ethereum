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
    
    fileprivate let boundContract: GethBoundContract
    fileprivate weak var context: GethContext?
    fileprivate weak var client: GethEthereumClient?
    
    init(with address: GethAddress, abi: String, context: GethContext, client: GethEthereumClient) {
        self.context = context
        self.client = client
        boundContract = GethBindContract(address, abi, client, nil)
    }
    
    func call(method: String, inputs: [GethInterface], outputs: [GethInterface]) throws {

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
        
        try boundContract.call(opts, out_: outs, method: method, args: args)
        
    }
    
}
