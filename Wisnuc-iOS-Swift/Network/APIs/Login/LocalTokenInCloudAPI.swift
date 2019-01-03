//
//  LocalTokenInCloudAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/1.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

//云获取本地Token
class LocalTokenInCloudAPI: BaseRequest {
    var cloudToken:String?
    var user:User?
    init(user:User? = nil,cloudToken:String? = nil) {
        if user != nil{
            self.user = user
        }
        self.cloudToken = cloudToken
    }
    
    override func requestURL() -> String {
        if let stationId = user?.stationId{
            let jsonURL = "/station/\(stationId)/json"
            return "\(kCloudBaseURL)\(jsonURL)"
        }
        return "\(kCloudBaseURL)\(kCloudCommonJsonUrl)"
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return .post
    }
    
    override func requestParameters() -> RequestParameters? {
        let token = "/token"
        let dic = [kRequestUrlPathKey:token,kRequestVerbKey:RequestMethodValue.GET]
        return dic
    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        
        if let cloudToken = user?.cloudToken,let cookie = user?.cookie{
            return [kRequestAuthorizationKey:cloudToken,kRequestSetCookieKey:cookie]
        }
        if let token = self.cloudToken{
            return  [kRequestAuthorizationKey:token,kRequestSetCookieKey:AppUserService.currentUser?.cookie ?? ""]
        }
        
        if let token = AppUserService.currentUser?.cloudToken{
          return [kRequestAuthorizationKey:token,kRequestSetCookieKey:AppUserService.currentUser?.cookie ?? ""]
        }
        return nil
    }
}
