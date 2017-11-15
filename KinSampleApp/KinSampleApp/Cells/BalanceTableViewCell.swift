//
//  BalanceTableViewCell.swift
//  KinSampleApp
//
//  Created by Natan Rolnik on 07/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK

class BalanceTableViewCell: KinClientCell {
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pendingBalanceLabel: UILabel!
    @IBOutlet weak var pendingBalanceActivityIndicator: UIActivityIndicatorView!

    var ongoingRequests = 0 {
        didSet {
            self.refreshButton.isEnabled = ongoingRequests == 0
        }
    }

    let numberFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencySymbol = ""

        return f
    }()

    override var kinClient: KinClient! {
        didSet {
            refreshBalance(self)
        }
    }

    @IBAction func refreshBalance(_ sender: Any) {
        let account = try! kinClient.createAccountIfNeeded(with: KinAccountPassphrase)!

        ongoingRequests += 1
        balanceActivityIndicator.startAnimating()
        account.balance { [weak self] balance, error in
            DispatchQueue.main.async {
                self?.balanceActivityIndicator.stopAnimating()
                self?.ongoingRequests -= 1

                guard let balance = balance,
                    error == nil else {
                        self?.balanceLabel.text = "Error"
                        return
                }

                if let formattedBalance = self?.numberFormatter.string(from: balance as NSDecimalNumber) {
                    self?.balanceLabel.text = "\(formattedBalance) KIN"
                }
            }
        }

        ongoingRequests += 1
        pendingBalanceActivityIndicator.startAnimating()
        account.pendingBalance { [weak self] pBalance, error in
            DispatchQueue.main.async {
                self?.pendingBalanceActivityIndicator.stopAnimating()
                self?.ongoingRequests -= 1

                guard let pBalance = pBalance,
                    error == nil else {
                        self?.pendingBalanceLabel.text = "Error"
                        return
                }

                if let formattedPendingBalance = self?.numberFormatter.string(from: pBalance as NSDecimalNumber) {
                    self?.pendingBalanceLabel.text = "\(formattedPendingBalance) KIN"
                }
            }
        }
    }
}
