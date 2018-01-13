//
//  Decimal+extensions.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

private let kinDecimal = Decimal(sign: .plus,
                                 exponent: -18,
                                 significand: Decimal(1))

extension Decimal {
    func kinToWei() -> Decimal {
        return self / kinDecimal
    }

    func weiToKin() -> Decimal {
        return self * kinDecimal
    }
}
