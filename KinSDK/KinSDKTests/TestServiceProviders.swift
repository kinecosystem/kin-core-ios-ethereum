//
//  TestServiceProviders.swift
//  KinSDKTests
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

struct NodeProvider: ServiceProvider {
    let url: URL
    let networkId: NetworkId

    init(networkId: NetworkId) {
        self.networkId = networkId
        switch networkId {
        case .mainNet:
            self.url = URL(string: "https://mainnet.infura.io/ciS27F9JQYk8MaJd8Fbu")!
        case .ropsten:
            self.url = URL(string: "https://ropsten.infura.io/ciS27F9JQYk8MaJd8Fbu")!
        case .truffle:
            self.url = URL(string: "http://localhost:8545")!
        default:
            fatalError("Unsupported network")
        }
    }
}
