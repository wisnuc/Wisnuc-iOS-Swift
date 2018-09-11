//
//  ViewTools.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/24.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents


let isX = __kWidth == 375 && __kHeight == 812 ? true : false
let is55InchScreen = __kWidth == 414 && __kHeight == 736 ? true : false
let is47InchScreen = __kWidth == 375 && __kHeight == 667 ? true : false
let is4InchScreen = __kWidth == 320 && __kHeight == 568 ? true : false

class ViewTools: NSObject {
    class func removeAllSuperViewExceptNavigationBar(view:UIView) {
        for view in view.subviews{
            if !view.isKind(of: MDCFlexibleHeaderView.self){
                view.removeFromSuperview()
            }
        }
    }
    
    class func removeAllSuperView(view:UIView) {
        for viewValue in view.subviews{
            viewValue.removeFromSuperview()
        }
    }
    
    class func automaticallyAdjustsScrollView(scrollView:UIScrollView,viewController:UIViewController){
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            viewController.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    class func setAlertControllerColor(alertController:MDCAlertController){
        let colorScheme = MDCSemanticColorScheme.init()
        colorScheme.primaryColor = COR1
        MDCAlertColorThemer.applySemanticColorScheme(colorScheme, to: alertController)
    }
}
