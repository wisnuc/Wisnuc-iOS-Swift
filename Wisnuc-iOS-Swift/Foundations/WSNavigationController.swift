//
//  WSNavigationController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/11.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import CatalogByConvention
import MaterialComponents.MDCNavigationBar

class WSNavigationController: UINavigationController {
    let appBar = MDCAppBar()
    override func viewDidLoad() {
        super.viewDidLoad()
      appBar.addSubviewsToParent()
    }
    
    override init(rootViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        self.setNavigationBarHidden(true, animated: false)
        self.appBar.navigationBar.backgroundColor = COR1
        appBar.headerViewController.headerView.backgroundColor = COR1
        appBar.navigationBar.titleView?.backgroundColor = .white
        // Step 2: Add the headerViewController as a child.
        self.addChildViewController(appBar.headerViewController)
        
        //        let color = UIColor(white: 0.2, alpha:1)
        //        appBar.headerViewController.headerView.backgroundColor = color
        appBar.navigationBar.tintColor = UIColor.white
        appBar.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var childViewControllerForStatusBarHidden: UIViewController? {
        return appBar.headerViewController
    }
    
    // Optional step: The Header View Controller does basic inspection of the header view's background
    //                color to identify whether the status bar should be light or dark-themed.
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return appBar.headerViewController
    }
    
    fileprivate lazy var customNavigationItem: UINavigationItem = UINavigationItem(title: "Profile")
    fileprivate lazy var customNavigationBar: UINavigationBar = {
        
        let bar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 64))
        
        bar.tintColor = COR1
        bar.tintAdjustmentMode = .normal
        bar.alpha = 1
        bar.setItems([self.customNavigationItem], animated: false)
        
        bar.backgroundColor = UIColor.clear
        bar.barStyle = UIBarStyle.blackTranslucent
        bar.isTranslucent = true
        bar.shadowImage = UIImage()
//        bar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        let textAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)
        ]
        
        bar.titleTextAttributes = textAttributes 
        
        return bar
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        guard navigationController != nil else {
            return
        }
        
        // 仅处理导航栏隐藏后重新显示，可在此做更多导航栏的统一效果处理
//        if navigationController.isNavigationBarHidden {
//            navigationController.setNavigationBarHidden(false, animated: animated)
//        }

    }
    
    override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(hidden, animated: animated)
        
        // 接管导航控制器的边缘侧滑返回交互手势代理
        interactivePopGestureRecognizer?.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
    
    
extension WSNavigationController: UIGestureRecognizerDelegate {
    // 让边缘侧滑手势在合适的情况下生效
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if (self.viewControllers.count > 1) {
            return true;
        }
        return false;
    }
    
    // 允许同时响应多个手势
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // 避免响应边缘侧滑返回手势时，当前控制器中的ScrollView跟着滑动
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.isKind(of: UIScreenEdgePanGestureRecognizer.self)
    }
    
}


