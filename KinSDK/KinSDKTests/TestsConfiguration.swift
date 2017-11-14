//
//  TestsConfiguration.swift
//  KinSDKTests
//
//  Created by Elazar Yifrach on 14/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Foundation

class TestsConfiguration {
    
    static let config:[String: Any]? = {
        if let fileUrl = Bundle.main.url(forResource: "testConfig", withExtension: "plist"),
            let data = try? Data(contentsOf: fileUrl),
            let configDict = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
            return configDict
        }
        return nil
    }()
    
   
    
}
