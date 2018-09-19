//
//  OnlySubscriberViewController.swift
//  Subscription
//
//  Created by 濱田裕史 on 2018/09/02.
//  Copyright © 2018年 濱田裕史. All rights reserved.
//

import UIKit

class OnlySubscriberViewController: UIViewController {
    var delegate: ModalViewControllerDelegate! = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(_ sender: Any) {
        delegate.finishModal()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
