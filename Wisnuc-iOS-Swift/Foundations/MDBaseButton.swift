//
//  MDBaseButton.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/19.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MDCButton

class MDBaseButton: MDCButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        MDCButtonColorThemer.apply(appDelegate.colorScheme, to: self)
//        self.sty
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
