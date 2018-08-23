//
//  Message.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/13.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents
import YYKit
class Message: NSObject {
    
    class func message(text:String ,duration:TimeInterval) -> Void{
        mainThreadSafe({
            let message  = MDCSnackbarMessage.init()
            message.text = text
            message.duration = duration
            MDCSnackbarManager.show(message)
        })
    }
    
    class func message(text:String) -> Void{
        mainThreadSafe({
            let message  = MDCSnackbarMessage.init()
            message.text = text
            message.duration = 2
            MDCSnackbarManager.show(message)
        })
    }
}
