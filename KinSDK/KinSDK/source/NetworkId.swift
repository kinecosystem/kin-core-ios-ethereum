//
//  NetworkId.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

/**
 `NetworkId` represents the Ethereum network to which `KinClient` will connect.
 */
public enum NetworkId {
    /**
     A production node.
     */
    case mainNet

    /**
     The ropsten test net.
     */
    case ropsten

    /**
     A local network setup by truffle (used by tests).
     */
    case truffle

    /**
     A network with a custom ID. **Currently unsupported**
     */
    case custom(value: UInt64)
}

extension NetworkId {
    func asInteger() -> UInt64 {
        switch self {
        case .mainNet:
            return 1
        case .ropsten:
            return 3
        case .truffle:
            return 9
        case .custom(let value):
            return value
        }
    }
}

extension NetworkId: CustomStringConvertible {
    /// :nodoc:
    public var description: String {
        switch self {
        case .mainNet:
            return "main"
        case .ropsten:
            return "ropsten"
        case .truffle:
            return "truffle"
        default:
            return "unsupported network"
        }
    }
}

extension NetworkId: Equatable {
    /// :nodoc:
    public static func == (lhs: NetworkId, rhs: NetworkId) -> Bool {
        return lhs.asInteger() == rhs.asInteger()
    }
}
