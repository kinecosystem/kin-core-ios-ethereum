//
//  Collection+extensions.swift
//  KinSDK
//
//  Created by Elazar Yifrach on 15/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

extension Collection where Iterator.Element == UInt8 {
    var data: Data {
        return Data(self)
    }
    var hexa: String {
        return map{ String(format: "%02X", $0) }.joined()
    }
}
