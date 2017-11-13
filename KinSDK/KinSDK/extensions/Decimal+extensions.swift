//
//  Decimal+extensions.swift
//  KinSDK
//
//  Created by Elazar Yifrach on 11/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

fileprivate let kinDecimal = Decimal(sign: .plus,
                                     exponent: -18,
                                     significand: Decimal(1))

extension Decimal {
    init(kinString: String) throws {
        guard let decimal = Decimal(string: kinString) else {
            throw KinError.invalidInput
        }
        if (kinString.count > -kinDecimal.exponent) {
            self.init(sign: .plus,
            exponent: kinDecimal.exponent,
            significand: decimal)
        } else {
            guard let uint = UInt64(kinString) else {
                throw KinError.invalidInput
            }
            self.init(sign: .plus, exponent: 0,
            significand: Decimal(uint))
        }
    }

    init(bigInt: GethBigInt) throws {
        try self.init(kinString: bigInt.string())
    }
}
