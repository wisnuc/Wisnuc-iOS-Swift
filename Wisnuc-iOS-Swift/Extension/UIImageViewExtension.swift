//
//  UIImageViewExtension.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/6.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import Foundation
public extension UIImageView {
    
    /// 图像像素
    public var pixels: [UInt32]? {
        return image?.extraPixels(in: bounds.size)
    }
    
    /// 将位置转换为像素索引
    ///
    /// - parameter point: 位置
    ///
    /// - returns: 像素索引
    public func pixelIndex(for point: CGPoint) -> Int? {
        let size = bounds.size
        guard point.x > 0 && point.x <= size.width
            && point.y > 0 && point.y <= size.height else {
                return nil
        }
        return (Int(point.y) * Int(size.width) + Int(point.x))
    }
    
    /// 将像素值转换为颜色
    ///
    /// - parameter pixel: 像素值
    ///
    /// - returns: 颜色
    public func extraColor(for pixel: UInt32) -> UIColor {
        let r = Int((pixel >> 0) & 0xff)
        let g = Int((pixel >> 8) & 0xff)
        let b = Int((pixel >> 16) & 0xff)
        let a = Int((pixel >> 24) & 0xff)
//        UIColor.init(red: r, green: <#T##CGFloat#>, blue: <#T##CGFloat#>, alpha: <#T##CGFloat#>)
        return UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
    }
}
