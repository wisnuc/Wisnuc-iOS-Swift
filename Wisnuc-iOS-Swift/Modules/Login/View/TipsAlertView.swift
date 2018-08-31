//
//  TipsAlertView.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/8/30.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

@objc protocol  TipsAlertViewDelegate{
    func alertDismiss(animateDuration:TimeInterval)
}

class TipsAlertView: UIView {
    let animateDuration = 0.2
    var delegate:TipsAlertViewDelegate?
    var isAlert:Bool = false
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
        
        let buttonReactWidth:CGFloat = 24
        self.errorTitleLabel.attributedText =  attributedText
        self.errorTitleLabel.numberOfLines = 0
        self.errorTitleLabel.frame = CGRect(x: MarginsWidth, y: MarginsWidth, width:__kWidth - 44 - MarginsWidth - buttonReactWidth, height: labelHeightFrom(title: message, font: font))
        self.addSubview(self.errorTitleLabel)
        self.frame = CGRect(x: 0, y: __kHeight, width: __kWidth, height: MarginsWidth*2 + self.errorTitleLabel.height)
        closeButton.frame = CGRect(x: __kWidth - MarginsWidth - buttonReactWidth, y: self.height/2 - buttonReactWidth/2, width: buttonReactWidth, height: buttonReactWidth)
        closeButton.addTarget(self, action: #selector(closeButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        self.addSubview(closeButton)
        kWindow?.addSubview(self)
        kWindow?.bringSubview(toFront: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(className()) deinit")
    }
    
    @objc func closeButtonTap(_ sender:UIButton){
       self.dismiss()
    }
    
    func alertDuration()->TimeInterval{
        return animateDuration
    }
    
    func alert() {
        if self.isAlert == true {
            dismiss()
        }
        
        UIView.animate(withDuration: animateDuration, animations: {
            self.center = CGPoint(x: self.center.x, y: self.center.y - self.height)
        }) { (finish) in
            self.isAlert = true
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: animateDuration, animations: {
            self.center = CGPoint(x: self.center.x, y: __kHeight -  self.height/2)
            self.delegate?.alertDismiss(animateDuration: self.animateDuration)
        }) { (finish) in
            self.isAlert = false
            self.removeFromSuperview()
        }
    }
    
    lazy var errorTitleLabel = UILabel.init()
    lazy var closeButton: UIButton = {
        let button = UIButton.init()
        button.setImage(UIImage.init(named: "x_gray"), for: UIControlState.normal)
        return button
    }()
}
