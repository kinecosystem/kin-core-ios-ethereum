//
//  SendTransactionViewController.swift
//  KinSampleApp
//
//  Created by Natan Rolnik on 12/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK

class SendTransactionViewController: UIViewController {
    var kinClient: KinClient!

    @IBOutlet weak var sendButton: UIButton!

    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        sendButton.fill(with: view.tintColor)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        amountTextField.becomeFirstResponder()
    }

    @objc func backgroundTapped() {
        view.endEditing(true)
    }

    @IBAction func sendTapped(_ sender: Any) {

//        guard let fields = validatedFields() else {
//            let alertController
//        }

        let account = try! kinClient.createAccountIfNeeded(with: KinAccountPassphrase)!

        let amount = UInt64(amountTextField.text ?? "0")!
        let address = addressTextField.text ?? ""

        account.sendTransaction(to: address, amount: amount, passphrase: KinAccountPassphrase) { transactionId, error in
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

                let alertController = UIAlertController(title: "Transaction Sent", message: "Transaction with ID \(transactionId) sent.", preferredStyle: .alert)
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

    //    func validatedFields() -> (String, UInt64)? {
//        return nil
//    }
}
