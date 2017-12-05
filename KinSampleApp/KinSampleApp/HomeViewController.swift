//
//  HomeViewController.swift
//  KinSampleApp
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK
import SafariServices

struct Provider: ServiceProvider {
    public let url: URL
    public let networkId: NetworkId

    init(url: URL, networkId: NetworkId) {
        self.url = url
        self.networkId = networkId
    }
}


class HomeViewController: UIViewController {
    @IBOutlet weak var testNetButton: UIButton!
    @IBOutlet weak var mainNetButton: UIButton!
    @IBOutlet weak var githubInfoStackView: UIStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }

        testNetButton.fill(with: UIColor.testNet)
        mainNetButton.fill(with: UIColor.mainNet)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(githubInfoTapped))
        githubInfoStackView.addGestureRecognizer(tapRecognizer)
    }

    @IBAction func networkSelected(_ sender: UIButton) {
        let production = sender == mainNetButton

        let provider: Provider
        if production {
            provider = Provider(url: URL(string: "http://mainnet.rounds.video:8545")!, networkId: .mainNet)
        } else {
            provider = Provider(url: URL(string: "http://parity.rounds.video:8545")!, networkId: .ropsten)
        }
        
        guard let kinClient = try? KinClient(provider: provider) else {
            print("Kin Client could not be created")
            return
        }

        if let kinAccount = kinClient.accounts[0] {
            //if we already have the account, pass it on to KinSampleViewController
            showSampleViewController(with: kinClient, kinAccount: kinAccount, production: production)
        } else {
            //if we don't have an account yet on the device, let's create one
            createKinAccount(with: kinClient, production: production)
        }
    }

    @objc func githubInfoTapped() {
        let safariViewController = SFSafariViewController(url: URL(string: "https://github.com/kinfoundation")!)
        present(safariViewController, animated: true, completion: nil)
    }

    func createKinAccount(with kinClient: KinClient, production: Bool) {
        let testOrMainNet = production ? "Main" : "Test"
        let alertController = UIAlertController(title: "No \(testOrMainNet) Net Wallet Yet", message: "Let's create a new one, using the kinClient.createAccountIfNeeded() api.", preferredStyle: .alert)
        let createWalletAction = UIAlertAction(title: "Create a Wallet", style: .default) { _ in
            do {
                let kinAccount = try kinClient.addAccount(with: KinAccountPassphrase)
                self.showSampleViewController(with: kinClient, kinAccount: kinAccount, production: production)
            } catch {
                print("KinAccount couldn't be created: \(error)")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(createWalletAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    func showSampleViewController(with kinClient: KinClient, kinAccount: KinAccount, production: Bool) {
        let sampleViewController = KinSampleViewController.instantiate(with: kinClient, kinAccount: kinAccount)
        sampleViewController.view.tintColor = production ? .mainNet : .testNet
        navigationController?.pushViewController(sampleViewController, animated: true)
    }
}

