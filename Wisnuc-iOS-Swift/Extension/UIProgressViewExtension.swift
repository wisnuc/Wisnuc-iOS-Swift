//
//  UIProgressViewExtension.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/15.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import Foundation

extension UIProgressView{
    
    func setRadiusTrackColor(_ trackColor: UIColor?) {
        let trackImage: UIImage? = image(with: trackColor, cornerRadius: frame.size.height / 2.0)
        self.trackImage = trackImage
    }
    
    func setRadiusProgressColor(_ progressColor: UIColor?) {
        let progressImage: UIImage? = image(with: progressColor, cornerRadius: frame.size.height / 2.0)
        self.progressImage = progressImage
    }
    
    func setRadiusTrackColor(_ trackColor: UIColor?, progressColor: UIColor?) {
        self.setRadiusTrackColor(trackColor)
        self.setRadiusProgressColor(progressColor)
    }
    
    //最小尺寸---1px
    private func edgeSizeWithRadius(cornerRadius: CGFloat) -> CGFloat {
        return cornerRadius * 2 + 1
    }
    
    func image(with color: UIColor?, cornerRadius: CGFloat) -> UIImage? {
        let minEdgeSize = edgeSizeWithRadius(cornerRadius: cornerRadius)
        let rect = CGRect(x: 0, y: 0, width: minEdgeSize, height: minEdgeSize)
        let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        roundedRect.lineWidth = 0
        UIGraphicsBeginImageContextWithOptions(rect.size, _: false, _: 0.0)
        color?.setFill()
        roundedRect.fill()
        roundedRect.stroke()
        roundedRect.addClip()
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.resizableImage(withCapInsets: UIEdgeInsetsMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius))
    }

}
