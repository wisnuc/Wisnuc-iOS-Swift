//
//  wechatInfoAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/30.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class WechatInfoAPI: BaseRequest {
    override func requestURL() -> String {
        return "/wechat"
    }
    
    override func baseURL() -> String {
        return kCloudBaseURL
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return  RequestHTTPMethod.get
    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        guard let token = AppUserService.currentUser?.cloudToken else {
            return nil
        }
        
        let params =  [kRequestAuthorizationKey:token]
        return params
    }
}
