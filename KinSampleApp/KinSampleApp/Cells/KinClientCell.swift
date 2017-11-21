//
//  KinClientCell.swift
//  KinSampleApp
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK

protocol KinClientCellDelegate: class {
    func revealKeyStore()
    func startSendTransaction()
    func getTestKin(cell: KinClientCell)
    func balanceDidUpdate(balance: Decimal, pendingBalance: Decimal)
}

class KinClientCell: UITableViewCell {
    weak var kinClientCellDelegate: KinClientCellDelegate?
    var kinClient: KinClient!
}

