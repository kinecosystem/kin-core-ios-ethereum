//
//  HomeViewController.swift
//  KinSampleApp
//
//  Created by Natan Rolnik on 06/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK
import SafariServices

struct Provider: ServiceProvider {
    public let url: URL
    public let networkId: UInt64

    init(url: URL, networkId: UInt64) {
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
            provider = Provider(url: URL(string: "https://mainnet.infura.io/ciS27F9JQYk8MaJd8Fbu")!, networkId: NetworkIdMain)
        } else {
            provider = Provider(url: URL(string: "http://207.154.247.11:8545")!, networkId: NetworkIdRopsten)
        }
        
        let kinClient = try! KinClient(provider: provider)
        
        let sampleViewController = KinSampleViewController.instantiate(with: kinClient)
        sampleViewController.view.tintColor = production ? .mainNet : .testNet
        navigationController?.pushViewController(sampleViewController, animated: true)
    }

    @objc func githubInfoTapped() {
        let safariViewController = SFSafariViewController(url: URL(string: "https://github.com/kinfoundation")!)
        present(safariViewController, animated: true, completion: nil)
    }
}

