//
//  Decimal+extensions.swift
//  KinSDK
//
//  Created by Elazar Yifrach on 11/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation
import KinSDKPrivate

fileprivate let kinDecimal = Decimal(sign: .plus,
                                     exponent: -18,
                                     significand: Decimal(1))

extension Decimal {
    init?(bigInt: GethBigInt) {
        self.init(string: bigInt.string())
    }

    func kinToWei() -> Decimal {
        return self / kinDecimal
    }

    func weiToKin() -> Decimal {
        return self * kinDecimal
    }

    func toBigInt() -> GethBigInt? {
        guard let b = GethNewBigInt(0) else {
            return nil
        }

        b.setString(self.description, base: 10)

        return b
    }
}
