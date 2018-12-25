//
//  LocalTokenInCloudAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/1.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

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
        var dic = [kRequestAuthorizationKey:AppUserService.currentUser?.cloudToken!,kRequestSetCookieKey:AppUserService.currentUser?.cookie ?? ""]
        if let token = self.cloudToken{
            dic = [kRequestAuthorizationKey:token,kRequestSetCookieKey:AppUserService.currentUser?.cookie ?? ""]
        }
        return dic as? RequestHTTPHeaders
    }
}
