//
//  UsersInfoAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/5.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class UsersInfoAPI: BaseRequest {
   
    override init() {
      super.init()
    }
    
    override func baseURL() -> String {
        return kCloudBaseURL
    }
    
    override func requestURL() -> String {
        return "/user"
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return RequestHTTPMethod.get
    }

    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        if let token = AppUserService.currentUser?.cloudToken{
            return [kRequestAuthorizationKey:token]
        }
        return nil
    }
}
