//
//  ViewController.swift
//  Sample3
//
//  Created by Zaid M. Said on 01/04/2018.
//  Copyright © 2018 Kiple Sdn Bhd. All rights reserved.
//

import UIKit

class ViewController: UIViewController, KPPaymentDelegate {

    let payment = KPPayment(merchantId: 48, storeId: 38, secret: "l43wrf8cai")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        payment.delegate = self
    }

    @IBAction func payButtonTapped(_ sender: UIButton) {
        self.payment.makePayment(referenceId: "3481", amount: 1.1)
    }

    func paymentDidFinish(successfully flag: Bool, withMessage message: String) {
        if flag {
            let alert = UIAlertController(title: "Sample App", message: "Payment is successful", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Sample App", message: "Payment is NOT successful", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

