//
//  ResultViewController.swift
//  QRCode
//
//  Created by Billow on 2020/2/6.
//  Copyright © 2020 Billow Wang. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    var qrcode: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = qrcode
    }

}
