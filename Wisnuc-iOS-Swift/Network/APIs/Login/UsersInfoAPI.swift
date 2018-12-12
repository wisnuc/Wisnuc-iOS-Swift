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
//        switch AppNetworkService.networkState {
//        case .normal?:
            return "/user"
//        case .local?:
//            return "/user"
//        default:
//            return ""
//        }
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return RequestHTTPMethod.get
    }
    
//    override func requestParameters() -> RequestParameters? {
//        var requestParameters:RequestParameters?
//        if disabled != nil {
//            requestParameters = ["disabled":disabled!]
//        }
//
//        if isAdmin != nil {
//            requestParameters = ["isAdmin":isAdmin!]
//        }
//        return requestParameters
//    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
//        switch AppNetworkService.networkState {
//        case .normal?:
            if let token = AppUserService.currentUser?.cloudToken{
                return [kRequestAuthorizationKey:token]
            }
            return nil
//        case .local?:
//            return [kRequestAuthorizationKey:JWTTokenString(token: AppTokenManager.token!)]
//        default:
//            return nil
//        }
    }
}
