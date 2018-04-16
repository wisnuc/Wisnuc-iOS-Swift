//
//  UIImageExtension.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/16.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import UIKit
extension UIImage {
    class func imageWithColor(color:UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

