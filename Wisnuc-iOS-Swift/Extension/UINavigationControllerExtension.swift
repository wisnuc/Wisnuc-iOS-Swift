//
//  UINavigationControllerExtension.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/11.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation

extension UINavigationController{
    func navigationBarShouldPopItem (navigationBar:UINavigationBar ,item:UINavigationItem) -> Bool {
        if self.viewControllers.count < (navigationBar.items?.count)! {
            return true
        }
        var shouldPop = true
        let currentVC = self.topViewController
        shouldPop = (currentVC?.navigationShouldPopOnBackButton())!
        //        }
        
        if (shouldPop == true)
        {
            DispatchQueue.main.async {
                self.popViewController(animated: true)
            }
            // 这里要return, 否则这个方法将会被再次调用
            return true
        }
        else
        {
            // 让系统backIndicator 按钮透明度恢复为1
            for subview in navigationBar.subviews
            {
                if (0.0 < subview.alpha && subview.alpha < 1.0) {
                    UIView.animate(withDuration: 0.25, animations: {
                        subview.alpha = 1.0
                    })
                }
            }
            return false
        }
    }
}


