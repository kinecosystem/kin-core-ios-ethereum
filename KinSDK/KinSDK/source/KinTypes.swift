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
    var networkId: NetworkId { get }
}

public typealias Balance = Decimal
public typealias TransactionId = String

public typealias TransactionCompletion = (TransactionId?, Error?) -> Void
public typealias BalanceCompletion = (Balance?, Error?) -> Void
