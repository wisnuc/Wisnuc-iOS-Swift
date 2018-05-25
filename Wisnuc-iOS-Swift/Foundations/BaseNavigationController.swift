//
//  BaseNavigationController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/14.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationBarHidden(true, animated: true)
        guard let navigationController = navigationController else {
            return
        }
        
        // 仅处理导航栏隐藏后重新显示，可在此做更多导航栏的统一效果处理
        if navigationController.isNavigationBarHidden {
            navigationController.setNavigationBarHidden(false, animated: animated)
        }
        
    }
    
    override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(hidden, animated: animated)
        
        // 接管导航控制器的边缘侧滑返回交互手势代理
        interactivePopGestureRecognizer?.delegate = self
    }
    
}

extension BaseNavigationController: UIGestureRecognizerDelegate {
    // 让边缘侧滑手势在合适的情况下生效
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if (self.viewControllers.count > 1) {
            return true
        }
        return false
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
