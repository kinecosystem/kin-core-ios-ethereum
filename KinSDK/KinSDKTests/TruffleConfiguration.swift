//
//  TruffleConfiguration.swift
//  KinSDKTests
//
//  Created by Avi Shevin on 16/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

struct TruffleConfiguration {
    static var configuration: [String: Any] = {
        guard let fileUrl = Bundle.main.url(forResource: "testConfig", withExtension: "plist"),
            let data = try? Data(contentsOf: fileUrl),
            let configDict = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: Any]  else {
                fatalError("Seems like you are trying to run tests on the local network, but " +
                    "the tests environment isn't correctly set up. Please see readme for more details")
        }
        return configDict
    }()

    static func privateKey(at: UInt) -> String {
        let key = "ACCOUNT_\(at)_PRIVATE_KEY"
        guard let privateKey = configuration[key] as? String else {
            fatalError("Unable to find private key for key: \(key)")
        }

        return privateKey
    }

    static let STARTING_BALANCE: Decimal = 1000
}

