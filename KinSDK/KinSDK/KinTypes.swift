//
//  KinMisc.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

public protocol ServiceProvider {
    var url: URL { get }
    var networkId: UInt64 { get }
}

public enum KinError: Error {
    case unknown
    case invalidInput
    case internalInconsistancy
    case invalidPassphrase
    case unsupportedNetwork
    case invalidAddress
    case invalidAmount
}

public let NetworkIdMain: UInt64 = 1
public let NetworkIdRopsten: UInt64 = 3
public let NetworkIdTruffle: UInt64 = 9

public typealias Balance = Decimal
public typealias TransactionId = String

public typealias TransactionCompletion = (TransactionId?, Error?) -> ()
public typealias BalanceCompletion = (Balance?, Error?) -> ()
