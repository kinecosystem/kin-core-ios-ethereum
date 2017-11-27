//
//  Bundle+extensions.swift
//  KinSDK
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

extension Bundle {
    class var kinResources: Bundle {
        let bundle = Bundle(for: Contract.self)
        if  let bundlePath = bundle.path(forResource: "KinSDK", ofType: "bundle"),
            let bundle = Bundle(path: bundlePath) {
            return bundle
        }
        return bundle
    }
}
