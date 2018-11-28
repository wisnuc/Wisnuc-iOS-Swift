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

    func compressQuality(withMaxLength maxLength: Int) -> Data? {
        var compression: CGFloat = 1
       
        var data =  UIImageJPEGRepresentation(self, compression)
        if (data?.count ?? 0) < maxLength {
            return data
        }
        var max: CGFloat = 1
        var min: CGFloat = 0
        for _ in 0..<6 {
            compression = (max + min) / 2
            data =  UIImageJPEGRepresentation(self, compression)
            if Double((data?.count ?? 0)) < Double(maxLength) * 0.9 {
                min = compression
            } else if (data?.count ?? 0) > maxLength {
                max = compression
            } else {
                break
            }
        }
        return data
    }
    
    
    class func scale(_ image: UIImage?, toScale scaleSize: Float) -> UIImage? {
        UIGraphicsBeginImageContext(CGSize(width: (image?.size.width ?? 0.0) * CGFloat(scaleSize), height: (image?.size.height ?? 0.0) * CGFloat(scaleSize)))
        image?.draw(in: CGRect(x: 0, y: 0, width: (image?.size.width ?? 0.0) * CGFloat(scaleSize), height: (image?.size.height ?? 0.0) * CGFloat(scaleSize)))
        let scaledImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    func was_roundImage(with size: CGSize, fill fillColor: UIColor?, opaque: Bool, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .default).async(execute: {
            //        NSTimeInterval start = CACurrentMediaTime();
            // 1. 利用绘图，建立上下文 BOOL选项为是否为不透明
            UIGraphicsBeginImageContextWithOptions(size, _: opaque, _: 0)
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            // 2. 设置填充颜色
            if opaque {
                fillColor?.setFill()
                UIRectFill(rect)
            }
            // 3. 利用 贝赛尔路径 `裁切 效果
            let path = UIBezierPath(ovalIn: rect)
            path.addClip()
            // 4. 绘制图像 如果图片为空那么为单色渲染
            
            self.draw(in: rect)
        
            // 5. 取得结果
            let result: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            // 6. 关闭上下文
            UIGraphicsEndImageContext()
            //        NSLog(@"%f", CACurrentMediaTime() - start);
            // 7. 完成回调
            DispatchQueue.main.async(execute: {
                completion(result)
            })
        })
    }
    
    func was_roundRectImage(with size: CGSize, fill fillColor: UIColor?, opaque: Bool, radius: CGFloat, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .default).async(execute: {
            //        NSTimeInterval start = CACurrentMediaTime();
            // 1. 利用绘图，建立上下文 BOOL选项为是否为不透明
            UIGraphicsBeginImageContextWithOptions(size, _: opaque, _: 0)
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            // 2. 设置填充颜色
            if opaque {
                fillColor?.setFill()
                UIRectFill(rect)
            }
            // 3. 利用 贝赛尔路径 `裁切 效果
            let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
            //        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
            path.addClip()
            // 4. 绘制图像
            
            self.draw(in: rect)
        
            // 5. 取得结果
            let result: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            // 6. 关闭上下文
            UIGraphicsEndImageContext()
            //        NSLog(@"%f", CACurrentMediaTime() - start);
            // 7. 完成回调
            DispatchQueue.main.async(execute: {
                completion(result)
            })
        })
    }
}

