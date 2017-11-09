//
//  HomeViewController.swift
//  KinSampleApp
//
//  Created by Natan Rolnik on 06/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK

class HomeViewController: UIViewController {
    @IBOutlet weak var testNetButton: UIButton!
    @IBOutlet weak var mainNetButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true

        testNetButton.setTitleColor(.white, for: .normal)
        testNetButton.setBackgroundImage(UIImage.from(UIColor.testNet), for: .normal)
        testNetButton.setBackgroundImage(UIImage.from(UIColor.testNet.withAlphaComponent(0.9)), for: .highlighted)

        mainNetButton.setTitleColor(.white, for: .normal)
        mainNetButton.setBackgroundImage(UIImage.from(UIColor.mainNet), for: .normal)
        mainNetButton.setBackgroundImage(UIImage.from(UIColor.mainNet.withAlphaComponent(0.9)), for: .highlighted)
    }

    @IBAction func networkSelected(_ sender: UIButton) {
//        let production = sender == mainNetButton

        let kinClient = KinClient(provider: InfuraTestProvider(apiKey: "ciS27F9JQYk8MaJd8Fbu"))
        let sampleViewController = KinSampleViewController.instantiate(with: kinClient)

        navigationController?.pushViewController(sampleViewController, animated: true)
    }
}

