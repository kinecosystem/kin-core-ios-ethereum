//
//  SendTransactionTableViewCell.swift
//  KinSampleApp
//
//  Created by Natan Rolnik on 12/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit

class SendTransactionTableViewCell: KinClientCell {
    @IBOutlet weak var sendButton: UIButton!

    override func tintColorDidChange() {
        super.tintColorDidChange()

        sendButton.fill(with: tintColor)
    }

    @IBAction func sendButtonTapped(_ sender: Any) {
        kinClientCellDelegate?.startSendTransaction()
    }
}
