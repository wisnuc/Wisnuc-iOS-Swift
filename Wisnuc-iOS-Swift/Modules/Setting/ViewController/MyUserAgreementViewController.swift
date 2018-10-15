//
//  MyUserAgreementViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/15.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class MyUserAgreementViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "close_white.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(dismiss(_ :)))
        // Do any additional setup after loading the view.
    }
    
    @objc func dismiss(_ sender:UIBarButtonItem){
        self.presentingViewController?.dismiss(animated: true, completion: {
            
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
