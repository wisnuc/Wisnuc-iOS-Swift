//
//  LoginViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/8/28.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController {

    override init(style: NavigationStyle) {
        super.init(style: style)
        prepareNavigationBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareNavigationBar(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: MDCIcons.imageFor_ic_arrow_back()?.byTintColor(UIColor.white), style: UIBarButtonItemStyle.plain, target: self, action: #selector(backButtonTap(_ :)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: LocalizedString(forKey: "忘记密码"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(forgetPwdTap(_ :)))
    }
    
    @objc func forgetPwdTap(_ sender:UIBarButtonItem){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func backButtonTap(_ sender:UIBarButtonItem){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}
