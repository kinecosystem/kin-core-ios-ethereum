//
//  KinError.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

public enum KinError: Error {
    case unknown
    case invalidInput
    case internalInconsistency
    case invalidPassphrase
    case unsupportedNetwork
    case invalidAddress
    case invalidAmount
    case insufficientBalance
}

extension KinError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Invalid Input"
        case .internalInconsistency:
            return "Internal Inconsistency"
        case .invalidPassphrase:
            return "Invalid Passphrase"
        case .unsupportedNetwork:
            return "Unsupported Network"
        case .invalidAddress:
            return "Invalid Address"
        case .invalidAmount:
            return "Invalid Amount"
        case .insufficientBalance:
            return "Not enough Kin"
        default:
            return "Unknown error"
        }
    }
}
