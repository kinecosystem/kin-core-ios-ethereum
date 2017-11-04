//
//  Contract.swift
//  KinSDK
//
//  Created by Elazar Yifrach on 04/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//
import Geth

protocol Contract {
    func call(method: String, inputs: [Any], outputs: [Any])
    init(with context: GethContext, client: GethEthereumClient)
}
