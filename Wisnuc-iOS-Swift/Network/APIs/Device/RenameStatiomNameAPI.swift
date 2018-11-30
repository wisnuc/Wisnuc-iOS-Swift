//
//  RenameStatiomNameAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/30.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class RenameStatiomNameAPI: NSObject {
    var name:String?
    init(name:String) {
        self.name = name
    }
    
    override func baseURL() -> String{
        if let lanIP = AppUserService.currentUser?.lanIP{
            return lanIP
        }
        return ""
    }
    
    override func requestURL() -> String {
        switch AppNetworkService.networkState {
        case .normal?:
            return kCloudCommonJsonUrl
        case .local?:
            return "/winasd/device"
        default:
            return ""
        }
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return .post
      
    }
    
    override func requestParameters() -> RequestParameters? {
        switch AppNetworkService.networkState {
        case .normal?:
            let urlPath = "/winasd/device"
            let params = ["name":name!]
            return [kRequestVerbKey:RequestMethodValue.GET,kRequestUrlPathKey:urlPath,kRequestImageParamsKey:params]
        case .local?:
            return nil
        default:
            return nil
        }
    }
    
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        switch AppNetworkService.networkState {
        case .normal?:
            return [kRequestAuthorizationKey:AppTokenManager.token!,kRequestSetCookieKey:AppUserService.currentUser?.cookie ?? ""]
        case .local?:
            return [kRequestAuthorizationKey:JWTTokenString(token: AppTokenManager.token!)]
        default:
            return nil
        }
    }
}
