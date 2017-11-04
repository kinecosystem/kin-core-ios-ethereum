//
//  KinResources.swift
//  KinSDK
//
//  Created by Elazar Yifrach on 04/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import Geth

struct KinResources {
    
    static var RopstenTestTokenAbi: String = {
        return try! String(contentsOfFile: Bundle.main.path(forResource: "RopstenTTTAbi", ofType: "json")!, encoding: .utf8)
    }()
    
    static var RopstenTestTokenContractAddress: GethAddress = {
        return GethNewAddressFromHex("0xef2fcc998847db203dea15fc49d0872c7614910c", nil)
    }()
    
}
