//
//  KinClientCell.swift
//  KinSampleApp
//
//  Created by Natan Rolnik on 07/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK

protocol KinClientCellDelegate: class {
    func revealKeyStore(keyStore: String)
    func startSendTransaction()
}

class KinClientCell: UITableViewCell {
    weak var kinClientCellDelegate: KinClientCellDelegate?
    var kinClient: KinClient!
}

