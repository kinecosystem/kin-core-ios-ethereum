//
//  SendTransactionViewController.swift
//  KinSampleApp
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK

class SendTransactionViewController: UIViewController {
    var kinAccount: KinAccount!

    @IBOutlet weak var sendButton: UIButton!

    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sendButton.fill(with: view.tintColor)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        amountTextField.becomeFirstResponder()
    }

    @IBAction func sendTapped(_ sender: Any) {
        let amount = UInt64(amountTextField.text ?? "0") ?? 0
        let address = addressTextField.text ?? ""

        kinAccount.sendTransaction(to: address,
                                   kin: Decimal(amount),
                                   passphrase: KinAccountPassphrase) { transactionId, error in
                                    DispatchQueue.main.async { [weak self] in
                                        guard let aSelf = self else {
                                            return
                                        }

                                        guard error == nil,
                                            let transactionId = transactionId else {
                                                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription ?? "No transaction ID", preferredStyle: .alert)
                                                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                                aSelf.present(alertController, animated: true, completion: nil)
                                                return
                                        }

                                        let message = "Transaction with ID \(transactionId) sent to \(address)"
                                        let alertController = UIAlertController(title: "Transaction Sent", message: message, preferredStyle: .alert)
                                        alertController.addAction(UIAlertAction(title: "Copy Transaction ID", style: .default, handler: { _ in
                                            UIPasteboard.general.string = transactionId
                                        }))
                                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                        aSelf.present(alertController, animated: true, completion: nil)
                                    }
        }
    }

    @IBAction func pasteTapped(_ sender: Any) {
        addressTextField.text = UIPasteboard.general.string
    }
}

extension SendTransactionViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let notDigitsSet = CharacterSet.decimalDigits.inverted
        let containsNotADigit = string.unicodeScalars.contains(where: notDigitsSet.contains)

        return !containsNotADigit
    }
}
