//
//  MediaRandomAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/6.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class MediaRandomAPI: BaseRequest {
    var  photoHash:String?
    init(hash: String) {
        self.photoHash = hash
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
    
    override func requestURL() -> String {
        switch AppNetworkService.networkState {
        case .normal?:
            return kCloudCommonJsonUrl
        case .local?:
            return "/media/\(self.photoHash!)"
        default:
            return ""
        }
    }
    
    override func requestParameters() -> RequestParameters? {
        switch AppNetworkService.networkState {
        case .normal?:
            let resurce = "/media/\(self.photoHash!)"
            let param = [kRequestImageAltKey:kRequestImageRandomValue]
            return [kRequestUrlPathKey:resurce,kRequestVerbKey:RequestMethodValue.GET,kRequestImageAltKey:kRequestImageRandomValue]
        case .local?:
            return [kRequestImageAltKey:kRequestImageRandomValue]
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
        return 60
    }
}
