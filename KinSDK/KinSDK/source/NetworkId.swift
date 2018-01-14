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
    The Stellar test net.
     */
    case testNet

    /**
     A network with a custom ID. **Currently unsupported**
     */
    case custom(issuer: String)
}

extension NetworkId {
    public var issuer: String {
        switch self {
        case .mainNet:
            return ""
        case .testNet:
            return "GBOJSMAO3YZ3CQYUJOUWWFV37IFLQVNVKHVRQDEJ4M3O364H5FEGGMBH"
        case .custom (let issuer):
            return issuer
        }
    }
}

extension NetworkId: CustomStringConvertible {
    /// :nodoc:
    public var description: String {
        switch self {
        case .mainNet:
            return "main"
        case .testNet:
            return "test"
        default:
            return "custom network"
        }
    }
}

extension NetworkId: Equatable {
    public static func ==(lhs: NetworkId, rhs: NetworkId) -> Bool {
        switch lhs {
        case .mainNet:
            switch rhs {
            case .mainNet:
                return true
            default:
                return false
            }
        case .testNet:
            switch rhs {
            case .testNet:
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
}
