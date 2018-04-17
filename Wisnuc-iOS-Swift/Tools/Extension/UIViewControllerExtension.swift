//
//  UIViewControllerExtension.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/17.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    class func currentViewController() -> UIViewController {
        let window = UIApplication.shared.keyWindow
        var controller = window?.rootViewController
        while true {
            if((controller?.presentedViewController) != nil){
                controller = controller?.presentedViewController
            }else{
                if (controller?.isKind(of: UINavigationController.self))!{
                    controller = controller?.childViewControllers.last
                }else if (controller?.isKind(of: UITabBarController.self))!{
                    let tabBarController = controller as! UITabBarController
                    controller = tabBarController.selectedViewController
                }else{
                    if (controller?.childViewControllers.count)!>0{
                        controller = controller?.childViewControllers.last
                    }else{
                        return controller!
                    }
                }
            }
        }
    }
}
