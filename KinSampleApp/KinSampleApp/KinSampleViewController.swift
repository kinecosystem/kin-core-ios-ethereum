//
//  KinSampleViewController.swift
//  KinSampleApp
//
//  Created by Natan Rolnik on 06/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK

class KinSampleViewController: UITableViewController {
    private var kinClient: KinClient!

    class func instantiate(with kinClient: KinClient) -> KinSampleViewController {
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "KinSampleViewController") as? KinSampleViewController else {
            fatalError("Couldn't load KinSampleViewController from Main.storyboard")
        }

        viewController.kinClient = kinClient

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
        txViewController.kinClient = kinClient
        navigationController?.pushViewController(txViewController, animated: true)
    }

    func getTestKin(cell: KinClientCell) {
        guard
            let account = try? kinClient.createAccountIfNeeded(with: KinAccountPassphrase),
            let address = account?.publicAddress,
            let getKinCell = cell as? GetKinTableViewCell else {
            return
        }

        getKinCell.getKinButton.isEnabled = false

        let urlString = "http://52.87.243.90:5000/send?public_address=\(address)"
        URLSession.shared.dataTask(with: URL(string: urlString)!) { [weak self] _, _, error in
            DispatchQueue.main.async {
                guard let aSelf = self,
                    error == nil else {
                        getKinCell.getKinButton.isEnabled = true
                        return
                }

                if let balanceCell = aSelf.tableView.visibleCells.flatMap({ $0 as? BalanceTableViewCell }).first {
                    balanceCell.refreshBalance(aSelf)
                }
            }
        }.resume()
    }

    func balanceDidUpdate(balance: Decimal, pendingBalance: Decimal) {
        guard let getKinCell = tableView.visibleCells.flatMap({ $0 as? GetKinTableViewCell }).first else {
            return
        }

        getKinCell.getKinButton.isEnabled = balance + pendingBalance == 0
    }
}
