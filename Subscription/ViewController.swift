//
//  ViewController.swift
//  Subscription
//
//  Created by 濱田裕史 on 2018/08/06.
//  Copyright © 2018年 濱田裕史. All rights reserved.
//

import UIKit

protocol ModalViewControllerDelegate {
    func finishModal() -> Void
}

class ViewController: UIViewController, ModalViewControllerDelegate {
    var onlySubscriberViewController: OnlySubscriberViewController!
    func finishModal() {
        onlySubscriberViewController.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func purchase(_ sender: Any) {
        PurchaseManager.shared.requestPurchase()
    }
    
    @IBAction func restore(_ sender: Any) {
        PurchaseManager.shared.restore()
        
    }
    @IBAction func nextPage(_ sender: Any) {
        
        let currentUnixTime:Int = Int(NSDate().timeIntervalSince1970)
        let expireDate:Int = UserDefaults.standard.integer(forKey: "expireDate")
        
        if expireDate > currentUnixTime {
            onlySubscriberViewController = self.storyboard?.instantiateViewController(withIdentifier: "OnlySubscriberViewController") as? OnlySubscriberViewController
            onlySubscriberViewController.delegate = self
            self.present(onlySubscriberViewController, animated: true, completion: nil)
        } else {
            let alert: UIAlertController = UIAlertController(title: nil, message: "購入してください", preferredStyle:  UIAlertControllerStyle.alert)
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
        
    }
}

