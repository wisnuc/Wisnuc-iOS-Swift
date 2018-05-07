//
//  WSTabBarController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/3.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents

class WSTabBarController: MDCTabBarViewController  {
    let bottomNavBar = MDCBottomNavigationBar()
    init() {
        super.init(nibName: nil, bundle: nil)
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    #if swift(>=3.2)
    @available(iOS 11, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

    }
    #endif
    
    func loadTabbar(){

    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hidesBottomBarWhenPushed = true
//        self.tabBar?.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension WSTabBarController:MDCTabBarControllerDelegate{
    func tabBarController(_ tabBarController: MDCTabBarViewController, didSelect viewController: UIViewController) {
//        print(viewController.tabBarItem.selectedImage!)
    }
}

