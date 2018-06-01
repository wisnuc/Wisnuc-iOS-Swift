//
//  TokenManager.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/13.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class TokenManager: NSObject {
    var token:String?{
        didSet{
            
        }
    }
    
    override init() {
        super.init()

    }
    
    class func wechatLoginToken()->String?{
        var tokenString:String?
        if AppUserService.currentUser != nil {
            tokenString = AppUserService.currentUser?.cloudToken
            return tokenString
        }else{
            let uuid = userDefaults.object(forKey: kCurrentUserUUID) as? String
            if uuid == nil || uuid?.count==0 {
                tokenString = nil
                return tokenString
            }else{
                let user = AppUserService.user(uuid: uuid!)
                tokenString = user?.cloudToken
                return tokenString
            }
        }
    }
}
