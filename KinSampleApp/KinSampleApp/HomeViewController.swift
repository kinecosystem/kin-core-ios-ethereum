//
//  HomeViewController.swift
//  KinSampleApp
//
//  Created by Natan Rolnik on 06/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK

struct ParityProvider: ServiceProvider {
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

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true

        testNetButton.fill(with: UIColor.testNet)
        mainNetButton.fill(with: UIColor.mainNet)
    }

    @IBAction func networkSelected(_ sender: UIButton) {
        let production = sender == mainNetButton

        let kinClient = try! KinClient(provider: ParityProvider(url: URL(string: "http://207.154.247.11:8545")!, networkId: 3))
//        let kinClient = try! KinClient(provider: InfuraTestProvider(apiKey: "ciS27F9JQYk8MaJd8Fbu"))
        let sampleViewController = KinSampleViewController.instantiate(with: kinClient)
        sampleViewController.view.tintColor = production ? .mainNet : .testNet

        navigationController?.pushViewController(sampleViewController, animated: true)
    }
}

