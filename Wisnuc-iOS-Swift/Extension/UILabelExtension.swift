//
//  UILabelExtension.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/11.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import Foundation
extension UILabel{
    class func initTitleLabel(color:UIColor,text:String) -> UILabel{
        let label = UILabel.init()
        label.text = text
        label.textColor = color
        label.font = UIFont.boldSystemFont(ofSize: 21)
        return label
    }
    
    class func initDetailTitleLabel(text:String,color:UIColor? = nil) -> UILabel{
        let label = UILabel.init()
        label.text = text
        if let color = color{
           label.textColor = color
        }else{
           label.textColor = LightGrayColor
        }
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }
}
