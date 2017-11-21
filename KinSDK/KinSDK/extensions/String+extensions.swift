//
//  String+extensions.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

extension String {
    var hexaBytes: [UInt8] {
        var position = startIndex
        return (0..<count/2).flatMap { _ in
            defer { position = index(position, offsetBy: 2) }
            return UInt8(self[position...index(after: position)], radix: 16)
        }
    }
    var hexaData: Data { return hexaBytes.data }
}
