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
    let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: __kWidth, height: 0));
    label.text = title
    label.font = font
    label.sizeToFit()
    return CGFloat(label.frame.size.width)
}

public func labelSize(title:String,font:UIFont) -> CGSize{
//    let size = (title as NSString).size(for: font, size: CGSize(width: CGFloat(MAXFLOAT), height: 40), mode: NSLineBreakMode.byWordWrapping)
//    let size = (title as NSString).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesFontLeading, attributes: [NSAttributedStringKey.font:font], context: nil).size
    // CGSize titleSize = [str boundingRectWithSize:CGSizeMake(lable.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]} context:nil].size;
    let size = (title as NSString).size(for: font, size: CGSize(width: CGFloat(MAXFLOAT), height: 40), mode: NSLineBreakMode.byCharWrapping)
    return size

}

public func labelSizeNoWordWrapping(title:String,font:UIFont) -> CGSize{
     let size = (title as NSString).size(for: font, size: CGSize(width: CGFloat(MAXFLOAT), height: 40), mode: NSLineBreakMode.byTruncatingTail)
    return size
}

public func labelHeightFrom(title:String,font:UIFont) -> CGFloat{
    let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0));
    label.text = title
    label.font = font
    label.sizeToFit()
    return CGFloat(label.frame.size.height)
}
