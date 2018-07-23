//
//  GetMediaAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/23.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class GetMediaAPI: BaseRequest {
    override func requestMethod() -> RequestHTTPMethod {
        return .get
    }
    
    override func requestURL() -> String {
        switch AppNetworkService.networkState {
        case .normal?:
            return kCloudCommonJsonUrl
        case .local?:
            return "/media"
        default:
            return ""
        }
    }
    
    override func requestParameters() -> RequestParameters? {
        switch AppNetworkService.networkState {
        case .normal?:
            return [kRequestResourceKey:"media".toBase64(),kRequestMethodKey:RequestMethodValue.GET]
        case .local?:
            return nil
        default:
            return nil
        }
    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        switch AppNetworkService.networkState {
        case .normal?:
            return [kRequestAuthorizationKey:AppTokenManager.token!]
        case .local?:
            return [kRequestAuthorizationKey:JWTTokenString(token: AppTokenManager.token!)]
        default:
            return nil
        }
    }
    
    override func timeoutIntervalForRequest() -> TimeInterval {
        return 2000
    }
}
