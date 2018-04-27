//
//  Message.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/13.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents

class Message: NSObject {
    
    class func message(text:String) -> Void{
        let message  = MDCSnackbarMessage.init()
        message.text = text
        message.duration = 2.0
        MDCSnackbarManager.show(message)
    }
}
