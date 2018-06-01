//
//  LocalTokenInCloudAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/1.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class LocalTokenInCloudAPI: BaseRequest {

    override func requestURL() -> String {
        return "\(kCloudBaseURL)/\(kCloudCommonJsonUrl)"
    }
    
    override func requestParameters() -> RequestParameters? {
        let token = "token"
        let resource = token.toBase64()
        let dic = [kRequestResourceKey:resource,kRequestMethodKey:RequestMethodValue.GET]
        return dic
    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        let dic = [kRequestAuthorizationKey:AppUserService.currentUser?.cloudToken!]
        return dic as? RequestHTTPHeaders
    }
}
