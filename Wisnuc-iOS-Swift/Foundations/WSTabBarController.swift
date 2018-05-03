//
//  WSTabBarController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/3.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents

class WSTabBarController: MDCTabBarViewController {
    let bottomNavBar = MDCBottomNavigationBar()
    init() {
        super.init(nibName: nil, bundle: nil)
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

  

        //    UIViewController *child1 = viewControllers[1];
        //    // Put the button under the header.
        //    MDCRaisedButton *button = [[MDCRaisedButton alloc] initWithFrame:CGRectMake(10, 120, 300, 40)];
        //    [button setTitle:@"Push and Hide Tab" forState:UIControlStateNormal];
        //    [button sizeToFit];
        //    [child1.view addSubview:button];
        //    [button addTarget:self
        //        action:@selector(pushHidesNavigation)
        //        forControlEvents:UIControlEventTouchUpInside];
        //
        //    UIViewController *child2 = viewControllers[2];
        //    // Put the button under the header.
        //    button = [[MDCRaisedButton alloc] initWithFrame:CGRectMake(10, 120, 300, 40)];
        //    [button setTitle:@"Toggle Tab Bar" forState:UIControlStateNormal];
        //    [button sizeToFit];
        //    [child2.view addSubview:button];
        //    [button addTarget:self
        //        action:@selector(toggleTabBar)
        //        forControlEvents:UIControlEventTouchUpInside];
        //
        //    MDCSemanticColorScheme *scheme = [[MDCSemanticColorScheme alloc] init];
        //    [MDCTabBarColorThemer applySemanticColorScheme:scheme toTabs:self.tabBar];
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

