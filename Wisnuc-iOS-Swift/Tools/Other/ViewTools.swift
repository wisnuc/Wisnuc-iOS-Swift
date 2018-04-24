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
}
