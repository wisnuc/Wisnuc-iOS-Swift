//
//  TipsAlertView.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/8/30.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class TipsAlertView: UIView {
    var errorMessage:String?
    init(errorMessage:String) {
        super.init(frame: CGRect.zero)
        self.backgroundColor = .white
        let error = LocalizedString(forKey: "错误")
        let message = "\(error) \(errorMessage)"
        
        let attributedText = NSMutableAttributedString.init(string: message)
        let font = UIFont.systemFont(ofSize: 14)
        attributedText.addAttribute(NSAttributedStringKey.font, value:font , range: NSRange.init(location: 0, length: attributedText.length))
        attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.colorFromRGB(rgbValue: 0x0e53935), range: NSRange.init(location: 0, length: 2))
        
        self.errorTitleLabel.attributedText =  attributedText
        self.errorTitleLabel.numberOfLines = 0
        self.errorTitleLabel.frame = CGRect(x: MarginsWidth, y: MarginsWidth, width: labelWidthFrom(title:message, font: font), height: labelHeightFrom(title: message, font: font))
        closeButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        self.addSubview(closeButton)
        self.addSubview(self.errorTitleLabel)
        self.frame = CGRect(x: 0, y: 0, width: __kWidth, height: MarginsWidth*2 + self.errorTitleLabel.height)
        kWindow?.addSubview(self)
        kWindow?.bringSubview(toFront: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func alert() {
        UIView.animate(withDuration: 0.3, animations: {
            self.center = CGPoint(x: self.center.x, y: self.center.y + self.height)
        }) { (finish) in
            
        }
    }
    
    lazy var errorTitleLabel = UILabel.init()
    lazy var closeButton: UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "x_gray"), for: UIControlState.normal)
        return button
    }()
}
