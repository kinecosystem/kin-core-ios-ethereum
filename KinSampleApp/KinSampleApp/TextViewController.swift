//
//  TextViewController.swift
//  KinSampleApp
//
//  Created by Natan Rolnik on 12/11/2017.
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {
    @IBOutlet private weak var textView: UITextView? {
        didSet {
            textView?.text = text

        }
    }

    var text: String? {
        didSet {
            textView?.text = text
        }
    }
}
