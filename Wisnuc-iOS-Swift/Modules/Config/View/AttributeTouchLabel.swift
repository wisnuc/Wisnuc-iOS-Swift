//
//  AttributeTouchLabel.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/13.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class AttributeTouchLabel: UIView {
    var content:String?{
        didSet{
            let attStr = NSMutableAttributedString.init(string: content!)
            
            attStr.addAttributes([NSAttributedStringKey.link : "click://"], range: NSMakeRange(6, 9))
//            addAttribute:NSLinkAttributeName value:@"click://" range:NSMakeRange(6, 9)];
            attStr.addAttributes([NSAttributedStringKey.foregroundColor:DarkGrayColor], range: NSMakeRange(6, 9))
            textView.attributedText = attStr
        }
    }
    var eventCallback:(()->())?
    override init(frame: CGRect) {
        super.init(frame: frame)
        textView.delegate = self
        textView.isEditable = false//必须禁止输入，否则点击将会弹出输入键盘
        textView.isScrollEnabled = false//可选的，视具体情况而定
        textView.textAlignment = .center
        self.addSubview(textView)
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var textView = UITextView.init(frame: self.bounds)
}

extension AttributeTouchLabel:UITextViewDelegate{
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.scheme == "click" {
            _ = textView.attributedText.attributedSubstring(from: characterRange)
            if self.eventCallback != nil {
                self.eventCallback!()
            }
            
            return false
        }
        return true
    }
}


