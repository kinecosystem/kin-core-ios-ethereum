//
//  KinToken.swift
//  KinSDK
//
//  Created by Elazar Yifrach on 11/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

public class KinToken {
    
    fileprivate let kinDecimal = Decimal(sign: .plus,
                                            exponent: -18,
                                            significand: Decimal(1))
    
    let value: Decimal
    
    init(string: String) throws {
        guard let decimal = Decimal(string: string) else {
            throw KinError.invalidInput
        }
        if (string.count > -kinDecimal.exponent) {
            self.value = Decimal(sign: .plus,
                                 exponent: kinDecimal.exponent,
                                 significand: decimal)
        } else {
            guard let uint = UInt64(string) else {
                throw KinError.invalidInput
            }
            self.value = Decimal(sign: .plus, exponent: 0,
                                 significand: Decimal(uint))
        }
    }
    
    convenience init(bigInt: GethBigInt) throws {
        try self.init(string: bigInt.string())
    }
    
    public init(value: UInt64) {
        self.value = Decimal(sign: .plus, exponent: 0, significand: Decimal(value))
    }
}
