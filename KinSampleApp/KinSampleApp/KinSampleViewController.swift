//
//  KinSampleViewController.swift
//  KinSampleApp
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK

class KinSampleViewController: UITableViewController {
    private var kinClient: KinClient!
    private var kinAccount: KinAccount!

    class func instantiate(with kinClient: KinClient, kinAccount: KinAccount) -> KinSampleViewController {
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "KinSampleViewController") as? KinSampleViewController else {
            fatalError("Couldn't load KinSampleViewController from Main.storyboard")
        }

        viewController.kinClient = kinClient
        viewController.kinAccount = kinAccount

        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }

        tableView.tableFooterView = UIView()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let kCell = cell as? KinClientCell {
            kCell.kinClient = kinClient
            kCell.kinAccount = kinAccount
            kCell.kinClientCellDelegate = self
        }
        
        return cell
    }
}

extension KinSampleViewController: KinClientCellDelegate {
    func revealKeyStore() {
        guard let keyStoreViewController = storyboard?.instantiateViewController(withIdentifier: "KeyStoreViewController") as? KeyStoreViewController else {
            return
        }

        keyStoreViewController.view.tintColor = view.tintColor
        keyStoreViewController.kinClient = kinClient
        navigationController?.pushViewController(keyStoreViewController, animated: true)
    }

    func startSendTransaction() {
        guard let txViewController = storyboard?.instantiateViewController(withIdentifier: "SendTransactionViewController") as? SendTransactionViewController else {
            return
        }

        txViewController.view.tintColor = view.tintColor
        txViewController.kinAccount = kinAccount
        navigationController?.pushViewController(txViewController, animated: true)
    }

    func deleteAccountTapped() {
        let alertController = UIAlertController(title: "Delete Wallet?",
                                                message: "Deleting a wallet when it hasn't been backed up will cause funds to be lost",
                                                preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "I've backed it up, delete wallet", style: .destructive) { _ in
            try? self.kinClient.deleteAccount(with: KinAccountPassphrase)
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    func getTestKin(cell: KinClientCell) {
        guard let getKinCell = cell as? GetKinTableViewCell else {
            return
        }

        getKinCell.getKinButton.isEnabled = false

        let urlString = "http://kin-faucet.rounds.video/send?public_address=\(kinAccount.publicAddress)"
        URLSession.shared.dataTask(with: URL(string: urlString)!) { [weak self] _, _, error in
            DispatchQueue.main.async {
                guard let aSelf = self else {
                    return
                }

                if let error = error {
                    getKinCell.getKinButton.isEnabled = true
                    print("Not able to get test Kin. \(error)")
                    return
                }

                UserDefaults.standard.set(true, forKey: GetKinSucceededOnce)

                if let balanceCell = aSelf.tableView.visibleCells.flatMap({ $0 as? BalanceTableViewCell }).first {
                    balanceCell.refreshBalance(aSelf)
                }
            }
        }.resume()
    }
}
