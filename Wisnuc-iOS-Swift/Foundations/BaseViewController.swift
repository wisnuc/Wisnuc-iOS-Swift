//
//  BaseViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/18.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents

class BaseViewController: UIViewController {
    let appBar = MDCAppBar()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.appBar.navigationBar.backgroundColor = COR1
        appBar.headerViewController.headerView.backgroundColor = COR1
        appBar.navigationBar.titleView?.backgroundColor = .white
        // Step 2: Add the headerViewController as a child.
        self.addChildViewController(appBar.headerViewController)
//        print(appBar.headerViewController.headerView.height)
//        let color = UIColor(white: 0.2, alpha:1)
//        appBar.headerViewController.headerView.backgroundColor = color
        appBar.navigationBar.tintColor = UIColor.white
        appBar.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white] as [NSAttributedStringKey : Any]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appBar.addSubviewsToParent()

        // Do any additional setup after loading the view.
    }
    
    
    override var childViewControllerForStatusBarHidden: UIViewController? {
        return appBar.headerViewController
    }
    
    // Optional step: The Header View Controller does basic inspection of the header view's background
    //                color to identify whether the status bar should be light or dark-themed.
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return appBar.headerViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
