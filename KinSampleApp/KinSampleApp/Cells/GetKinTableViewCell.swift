//
//  GetKinTableViewCell.swift
//  KinSampleApp
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit

class GetKinTableViewCell: KinClientCell {
    @IBOutlet weak var getKinButton: UIButton!

    override func tintColorDidChange() {
        super.tintColorDidChange()

        getKinButton.fill(with: tintColor)
    }

    @IBAction func getKinTapped(_ sender: Any) {
        kinClientCellDelegate?.getTestKin(cell: self)
    }
}
