//
//  UIImageViewExtension.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/6.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import Foundation
import Kingfisher
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
    
    
    //圆
    func was_setCircleImage(withUrlString urlString: String?, placeholder image: UIImage?, fill color: UIColor?) {
        was_setCircleImage(withUrlString: urlString ?? "", placeholder: image, fill: color, opaque: (color != nil))
    }
    //网络延迟下载--圆形 背景色为透明 无背景色
    func was_setCircleImage(withUrlString urlString: String?, placeholder image: UIImage?) {
        was_setCircleImage(withUrlString: urlString, placeholder: image, fill: nil, opaque: false)
    }
    //圆形矩阵
    func was_setRoundRectImage(withUrlString urlString: String?, placeholder image: UIImage?, fill color: UIColor?, cornerRadius: CGFloat) {
        was_setRoundRectImage(withUrlString: urlString, placeholder: image, fill: color, opaque: (color != nil), cornerRadius: cornerRadius)
    }
    //网络延迟下载--圆形矩阵 背景色为透明 无背景色
    func was_setRoundRectImage(withUrlString urlString: String?, placeholder image: UIImage?, cornerRadius: CGFloat) {
        was_setRoundRectImage(withUrlString: urlString, placeholder: image, fill: nil, opaque: false, cornerRadius: cornerRadius)
    }
    
    func was_setCircleImage(withUrlString urlString: String?, placeholder image: UIImage?, fill color: UIColor?, opaque: Bool) {
        superview?.layoutIfNeeded()
        guard let url = URL(string: urlString ?? "") else {
            if let placeholder = image{
                self.image = placeholder
            }
            return
        }
        //防止循环引用
        var size: CGSize = frame.size
        if image != nil {
            //占位图片不为空的情况
            //1.现将占位图圆角化，这样就避免了如图片下载失败，使用占位图的时候占位图不是圆角的问题
            //占位图片不为空的情况
            //1.现将占位图圆角化，这样就避免了如图片下载失败，使用占位图的时候占位图不是圆角的问题
            image?.was_roundImage(with: size, fill: color, opaque: opaque) { [weak self] (radiusPlaceHolder) in
                //2.使用sd的方法缓存异步下载的图片
//                self?.image = image
                ImageDownloader.default.downloadTimeout = 20000
                let _ =  ImageDownloader.default.downloadImage(with: url, retrieveImageTask: nil, options: [.originalCache(ImageCache.default)], completionHandler: { (img, error, dUrl, data) in
                    if img == nil || error != nil {
                        if size.height == 0 || size.width == 0 {
                            if let image = image {
                              size = image.size
                            }
                        }
                        image?.was_roundImage(with: size, fill: color, opaque: opaque) { radiusImage in
                            self?.image = radiusImage
                        }
                    } else {
                        if let img = img,let url = dUrl{
                            ImageCache.default.store(img,
                                                     original: data,
                                                     forKey: url.absoluteString,
                                                     toDisk: true)
                        }
                        if size.height == 0 || size.width == 0 {
                            if let image = image {
                                size = image.size
                            }
                        }
                        img?.was_roundImage(with: size, fill: color, opaque: opaque) { radiusImage in
                            self?.image = radiusImage
                        }
                    }
                })
            }
        } else {
            //占位图片为空的情况
            //2.使用sd的方法缓存异步下载的图片
            ImageDownloader.default.downloadTimeout = 20000
            let _ =  ImageDownloader.default.downloadImage(with: url, completionHandler: { (img, error, url, data) in
                //3.如果下载成功那么讲下载成功的图进行圆角化
                img?.was_roundImage(with: size, fill: color, opaque: opaque, completion: { [weak self](radiusImage) in
                    self?.image = radiusImage
                })
            })
        }
    }
    
    
    func was_setRoundRectImage(withUrlString urlString: String?, placeholder image: UIImage?, fill color: UIColor?, opaque: Bool, cornerRadius: CGFloat) {
        superview?.layoutIfNeeded()
        guard let url = URL(string: urlString ?? "" ) else {
            if let placeholder = image{
                self.image = placeholder
            }
            return
        }
        //防止循环引用
        weak var weakSelf = self
        let size: CGSize = frame.size
        if image != nil {
            //占位图片不为空的情况
            //1.现将占位图圆角化，这样就避免了如图片下载失败，使用占位图的时候占位图不是圆角的问题
            image?.was_roundRectImage(with: size, fill: color, opaque: opaque, radius: cornerRadius) { roundRectPlaceHolder in
                //2.使用sd的方法缓存异步下载的图片
                ImageDownloader.default.downloadTimeout = 20000
                let _ =  ImageDownloader.default.downloadImage(with: url, completionHandler: { (img, error, url, data) in
                    //3.如果下载成功那么讲下载成功的图进行圆角化
                    img?.was_roundRectImage(with: size, fill: color, opaque: opaque, radius: cornerRadius) { radiusImage in
                        weakSelf?.image = radiusImage
                    }
                })
            }
        } else {
            //占位图片为空的情况
            //.使用sd的方法缓存异步下载的图片
             let _ =  ImageDownloader.default.downloadImage(with: url, completionHandler: { (img, error, url, data) in
                //3.如果下载成功那么讲下载成功的图进行圆角化
                img?.was_roundRectImage(with: size, fill: color, opaque: opaque, radius: cornerRadius) { radiusImage in
                    weakSelf?.image = radiusImage
                }
            })
        }
    }
}
