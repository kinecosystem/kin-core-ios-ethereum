//
//  TestServiceProviders.swift
//  KinSDKTests
//
//  Created by Elazar Yifrach on 08/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

struct NodeProvider: ServiceProvider {
    let url: URL
    let networkId: UInt64
    
    init(networkId: UInt64) {
        self.networkId = networkId
        switch networkId {
        case NetworkIdMain:
            self.url = URL(string: "https://mainnet.infura.io/ciS27F9JQYk8MaJd8Fbu")!
        case NetworkIdRopsten:
            self.url = URL(string: "https://ropsten.infura.io/ciS27F9JQYk8MaJd8Fbu")!
        case NetworkIdTruffle:
            self.url = URL(string: "http://localhost:8545")!
        default:
            fatalError("Unsupported network")
        }
    }
}
