//
//  TextFiledExtension.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/8/31.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
extension UITextField {
    
    enum PaddingSide {
        case left(CGFloat)
        case right(CGFloat)
        case both(CGFloat)
    }
    
    func addPadding(_ padding: PaddingSide) {
        
        self.leftViewMode = .always
        self.layer.masksToBounds = true
        
        
        switch padding {
            
        case .left(let spacing):
            self.leftView?.frame = CGRect(x: 0, y: 0, width: (self.leftView?.width)! + spacing, height: self.frame.height)

            
        case .right(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            self.rightView = paddingView
     
        case .both(let spacing):
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: spacing, height: self.frame.height))
            // left
            self.leftView = paddingView
       
            // right
            self.rightView = paddingView

        }
    }
    
}
