//
//  RenameStatiomNameAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/30.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

//更改station名称API
class RenameStatiomNameAPI: BaseRequest {
    var name:String?
    init(name:String) {
        self.name = name
    }
    
    override func baseURL() -> String{
        switch AppNetworkService.networkState {
        case .normal?:
            return kCloudBaseURL
        case .local?:
            if let lanIP = AppUserService.currentUser?.lanIP{
                return "http://\(lanIP):3001"
            }
        default:
            return ""
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
            return [kRequestVerbKey:RequestMethodValue.POST,kRequestUrlPathKey:urlPath,kRequestImageParamsKey:params]
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
