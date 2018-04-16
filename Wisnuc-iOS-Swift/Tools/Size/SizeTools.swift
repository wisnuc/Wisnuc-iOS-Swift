//
//  SizeTools.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/11.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import UIKit

public func labelWidthFrom(title:String,font:UIFont) -> CGFloat{
    let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: 1000, height: 0));
    label.text = title
    label.font = font
    label.sizeToFit()
    return CGFloat(label.frame.size.width)
}

public func labelHeightFrom(title:String,font:UIFont) -> CGFloat{
    let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: 1000, height: 0));
    label.text = title
    label.font = font
    label.sizeToFit()
    return CGFloat(label.frame.size.height)
}
