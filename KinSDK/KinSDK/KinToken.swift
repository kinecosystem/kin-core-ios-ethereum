//
//  KinToken.swift
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
    static func decimal(with string: String) throws -> Decimal {
        guard let decimal = Decimal(string: string) else {
            throw KinError.invalidInput
        }
        if (string.count > -kinDecimal.exponent) {
            return Decimal(sign: .plus,
                                 exponent: kinDecimal.exponent,
                                 significand: decimal)
        } else {
            guard let uint = UInt64(string) else {
                throw KinError.invalidInput
            }
            return Decimal(sign: .plus, exponent: 0,
                                 significand: Decimal(uint))
        }
    }

    static func decimal(with bigInt: GethBigInt) throws -> Decimal {
        return try self.decimal(with: bigInt.string())
    }
}
