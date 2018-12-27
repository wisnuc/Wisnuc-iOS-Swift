//
//  BindStationAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/14.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class BindStationAPI: BaseRequest {
    var user:User?
    init(user:User?) {
        self.user = user
    }
    
    override func requestURL() -> String {
        return "/station"
    }
    
    override func baseURL() -> String {
        return kCloudBaseURL
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return RequestHTTPMethod.post
    }
    
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        if let token = self.user?.cloudToken{
            return [kRequestAuthorizationKey:token]
        }
        return [kRequestAuthorizationKey:AppUserService.currentUser?.cloudToken ?? ""]
    }
}
