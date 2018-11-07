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
    
    /// 根据图片大小提取像素
    ///
    /// - parameter size: 图片大小
    ///
    /// - returns: 像素数组
    public func extraPixels(in size: CGSize) -> [UInt32]? {
        
        guard let cgImage = cgImage else {
            return nil
        }
        
        let width = Int(size.width)
        let height = Int(size.height)
        // 一个像素 4 个字节，则一行共 4 * width 个字节
        let bytesPerRow = 4 * width
        // 每个像素元素位数为 8 bit，即 rgba 每位各 1 个字节
        let bitsPerComponent = 8
        // 颜色空间为 RGB，这决定了输出颜色的编码是 RGB 还是其他（比如 YUV）
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        // 设置位图颜色分布为 RGBA
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        var pixelsData = [UInt32](repeatElement(0, count: width * height))
        
        guard let content = CGContext(data: &pixelsData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return nil
        }
        
        content.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return pixelsData
    }

}

