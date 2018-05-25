//
//  TokenManager.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/13.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class TokenManager: NSObject {
    class func wechatLoginToken()->String?{
        var tokenString:String?
        tokenString = userDefaults.object(forKey: kCurrentUserUUID) as? String
        return tokenString
    }
}
