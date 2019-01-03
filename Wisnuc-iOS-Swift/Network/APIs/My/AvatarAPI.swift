
//
//  AvatarAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/27.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

//用户头像操作API
class AvatarAPI: BaseRequest {
    override func requestURL() -> String {
        return "/user/avatar"
    }
    
    override func baseURL() -> String {
        return kCloudBaseURL
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return  RequestHTTPMethod.put
    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        guard let token = AppUserService.currentUser?.cloudToken else {
            return nil
        }
        
        let params =  [kRequestAuthorizationKey:token]
        return params
    }
    
    override func timeoutIntervalForRequest() -> TimeInterval {
        return TimeInterval(300)
    }
}
