//
//  BootAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/23.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire
class BootSpaceAPI: BaseRequest {
    override func requestURL() -> String {
        switch AppNetworkService.networkState {
        case .normal?:
            return kCloudCommonJsonUrl
        case .local?:
            return "/boot/space"
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
            let urlPath = "/boot/space"
            return [kRequestVerbKey:RequestMethodValue.GET,kRequestUrlPathKey:urlPath]
        case .local?:
            return nil
        default:
            return nil
        }
    }
    
    override func requestEncoding() -> RequestParameterEncoding {
        return  requestMethod() == RequestHTTPMethod.get ? URLEncoding.default : JSONEncoding.default
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
