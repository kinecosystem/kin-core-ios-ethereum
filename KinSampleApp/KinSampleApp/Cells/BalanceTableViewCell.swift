//
//  BalanceTableViewCell.swift
//  KinSampleApp
//
//  Created by Natan Rolnik on 07/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit

class BalanceTableViewCell: KinClientCell {

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var pendingBalanceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func refreshTapped(_ sender: UIButton) {
        let account = try! kinClient.createAccountIfNeeded(with: KinAccountPassphrase)!

        let balance = try? account.balance()
    }
}
