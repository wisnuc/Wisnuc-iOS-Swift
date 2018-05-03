//
//  OSTools.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/20.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import UIKit

public func sgm_safeAreaInset(view:UIView) -> UIEdgeInsets{
     if #available(iOS 11.0, *) {
        return view.safeAreaInsets
    }
    return UIEdgeInsets.zero
}

extension UIDevice {
    public func isX() -> Bool {
        if UIScreen.main.bounds.height == 812 {
            return true
        }
        return false
    }
}

