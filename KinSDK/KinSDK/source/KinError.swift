//
//  KinError.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

/**
 Operations performed by the KinSDK that throw errors might throw a `KinError`; alternatively,
 errors in completion blocks might be of this type.
 */
public enum KinError: Error {
    /**
     An internal error happened in the KinSDK.
     */
    case internalInconsistency

    /**
     Thrown when any operation that requires a passphrase receives the wrong passphrase.
     */
    case invalidPassphrase

    /**
     An invalid address was used as a recipient in a transaction.
     */
    case invalidAddress

    /**
     Amounts must be greater than zero when trying to transfer Kin. When sending 0 Kin, this error
     is thrown.
     */
    case invalidAmount

    /**
     Thrown when trying to send more than the available Kin.
     */
    case insufficientBalance

    /**
     An unknown error happened.
     */
    case unknown
}

extension KinError: LocalizedError {
    /// :nodoc:
    public var errorDescription: String? {
        switch self {
        case .internalInconsistency:
            return "Internal Inconsistency"
        case .invalidPassphrase:
            return "Invalid Passphrase"
        case .invalidAddress:
            return "Invalid Address"
        case .invalidAmount:
            return "Invalid Amount"
        case .insufficientBalance:
            return "Not Enough Kin"
        case .unknown:
            return "Unknown Error"
        }
    }
}
