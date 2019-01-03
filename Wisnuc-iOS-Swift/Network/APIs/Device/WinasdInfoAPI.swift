//
//  WinasdInfoAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/30.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

//station信息（3001）
class WinasdInfoAPI: BaseRequest {
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
            return "/winasd/info"
        default:
            return ""
        }
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        switch AppNetworkService.networkState {
        case .normal?:
            return .post
        case .local?:
            return .get
        default:
            return .get
        }
    }
    
    
    
    override func requestParameters() -> RequestParameters? {
        switch AppNetworkService.networkState {
        case .normal?:
            let urlPath = "/winasd/info"
            return [kRequestVerbKey:RequestMethodValue.GET,kRequestUrlPathKey:urlPath]
        case .local?:
            return nil
        default:
            return nil
        }
    }
    
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        switch AppNetworkService.networkState {
        case .normal?:
            if let token = AppUserService.currentUser?.cloudToken{
               return [kRequestAuthorizationKey:token,kRequestSetCookieKey:AppUserService.currentUser?.cookie ?? ""]
            }
           return nil
        case .local?:
            return [kRequestAuthorizationKey:JWTTokenString(token: AppTokenManager.token!)]
        default:
            return nil
        }
    }
}
