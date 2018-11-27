//
//  DeviceNetAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/26.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class DeviceNetAPI: BaseRequest {
    override func requestURL() -> String {
        switch AppNetworkService.networkState {
        case .normal?:
            return kCloudCommonJsonUrl
        case .local?:
            return "/device/net"
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
            let urlPath = "/device/net"
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
            return [kRequestAuthorizationKey:AppTokenManager.token!,kRequestSetCookieKey:AppUserService.currentUser?.cookie ?? ""]
        case .local?:
            return [kRequestAuthorizationKey:JWTTokenString(token: AppTokenManager.token!)]
        default:
            return nil
        }
    }
}
