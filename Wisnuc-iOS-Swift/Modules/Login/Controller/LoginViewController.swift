//
//  LoginViewController.swift
//  FruitMix-Swift
//
//  Created by wisnuc-imac on 2018/3/16.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import SnapKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
