//
//  KinAccountTableViewCell.swift
//  KinSampleApp
//
//  Created by Natan Rolnik on 12/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK

class KinAccountTableViewCell: KinClientCell {
    @IBOutlet weak var addressLabel: UILabel!

    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    override var kinClient: KinClient! {
        didSet {
            showAddress()
        }
    }

    @IBAction func revealKeyStore(_ sender: Any) {
        kinClientCellDelegate?.revealKeyStore()
    }

    @IBAction func copyAddress(_ sender: Any) {
        UIPasteboard.general.string = addressLabel.text
    }

    func showAddress() {
        let account = try! kinClient.createAccountIfNeeded(with: KinAccountPassphrase)!
        addressLabel.text = account.publicAddress
    }
}
