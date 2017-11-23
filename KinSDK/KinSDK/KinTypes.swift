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

public let networkIdMain: UInt64 = 1
public let networkIdRopsten: UInt64 = 3
public let networkIdTruffle: UInt64 = 9

public typealias Balance = Decimal
public typealias TransactionId = String

public typealias TransactionCompletion = (TransactionId?, Error?) -> Void
public typealias BalanceCompletion = (Balance?, Error?) -> Void
