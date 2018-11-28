//
//  UIButttonExtension.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/17.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

extension UIButton{
    //圆形
    func was_setCircleImage(withUrlString urlString: String?, placeholder image: UIImage?, fill color: UIColor?, for state: UIControl.State) {
        was_setCircleImage(withUrlString: urlString, placeholder: image, fill: color, opaque: (color != nil), for: state)
    }
    //button--圆形    背景为透明 无背景色
    func was_setCircleImage(withUrlString urlString: String?, placeholder image: UIImage?, for state: UIControl.State) {
        was_setCircleImage(withUrlString: urlString, placeholder: image, fill: nil, opaque: false, for: state)
    }
    //圆角矩阵
    func was_setRoundRectImage(withUrlString urlString: String?, placeholder image: UIImage?, fill color: UIColor?, cornerRadius: CGFloat, for state: UIControl.State) {
        was_setRoundRectImage(withUrlString: urlString, placeholder: image, fill: color, opaque: (color != nil), cornerRadius: cornerRadius, for: state)
    }
    //button--圆角矩形 背景为透明 无背景色
    func was_setRoundRectImage(withUrlString urlString: String?, placeholder image: UIImage?, cornerRadius: CGFloat, for state: UIControl.State) {
        was_setRoundRectImage(withUrlString: urlString, placeholder: image, fill: nil, opaque: false, cornerRadius: cornerRadius, for: state)
    }
    
    func was_setRoundRectImage(withUrlString urlString: String?, placeholder image: UIImage?, fill color: UIColor?, opaque: Bool, cornerRadius: CGFloat, for state: UIControl.State) {
        guard let url = URL(string: urlString ?? "" ) else {
            if let placeholder = image{
                self.setImage(placeholder, for: state)
            }
            return
        }
        superview?.layoutIfNeeded()
        weak var weakSelf = self
        let size: CGSize = frame.size
        if image != nil {
            //占位图片不为空的情况
            //占位处理
            image?.was_roundRectImage(with: size, fill: color, opaque: opaque, radius: cornerRadius) { roundRectPlaceHolder in
                //sd
                ImageDownloader.default.downloadTimeout = 20000
                let _ =  ImageDownloader.default.downloadImage(with: url, completionHandler: { (img, error, url, data) in
                    //3.如果下载成功那么讲下载成功的图进行圆角化
                    img?.was_roundRectImage(with: size, fill: color, opaque: opaque, radius: cornerRadius) { roundRectImage in
                        weakSelf?.setImage(roundRectImage, for: state)
                    }
                })
            }
        } else {
            //占位图片为空的情况
            ImageDownloader.default.downloadTimeout = 20000
            let _ =  ImageDownloader.default.downloadImage(with: url, completionHandler: { (img, error, url, data) in
                //3.如果下载成功那么讲下载成功的图进行圆角化
                img?.was_roundRectImage(with: size, fill: color, opaque: opaque, radius: cornerRadius) { roundRectImage in
                    weakSelf?.setImage(roundRectImage, for: state)
                }
            })
        }
    }
    
    func was_setCircleImage(withUrlString urlString: String?, placeholder image: UIImage?, fill color: UIColor?, opaque: Bool, for state: UIControl.State) {
        guard let url = URL(string: urlString ?? "" ) else {
            if let placeholder = image{
               self.setImage(placeholder, for: state)
            }
            return
        }
        superview?.layoutIfNeeded()
        weak var weakSelf = self
        let size: CGSize = frame.size
        if image != nil {
            //占位图片不为空的情况
            //占位处理
            image?.was_roundImage(with: size, fill: color, opaque: opaque) { radiusPlaceHolder in
                //sd
                ImageDownloader.default.downloadTimeout = 20000
                let _ =  ImageDownloader.default.downloadImage(with: url, completionHandler: { (img, error, url, data) in
                    //3.如果下载成功那么讲下载成功?的图进行圆角化
                    img?.was_roundImage(with: size, fill: color, opaque: opaque) { radiusImage in
                        weakSelf?.setImage(radiusImage, for: state)
                    }
                })
            }
        } else {
            //占位图片为空的情况
            ImageDownloader.default.downloadTimeout = 20000
            let _ =  ImageDownloader.default.downloadImage(with: url, completionHandler: { (img, error, url, data) in
                //3.如果下载成功那么讲下?载成功的图进行圆角化
                img?.was_roundImage(with: size, fill: color, opaque: opaque) { radiusImage in
                    weakSelf?.setImage(radiusImage, for: state)
                }
            })
        }
    }
}


