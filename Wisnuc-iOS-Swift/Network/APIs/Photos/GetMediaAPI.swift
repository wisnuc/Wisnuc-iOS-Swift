//
//  GetMediaAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/23.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class GetMediaAPI: BaseRequest {
    var classType:String?
    var placesUUID:String?
    init(classType:String,placesUUID:String) {
        self.classType = classType
        self.placesUUID = placesUUID
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
            return "/files"
        default:
            return ""
        }
    }
    
    override func requestParameters() -> RequestParameters? {
        switch AppNetworkService.networkState {
        case .normal?:
            return [kRequestUrlPathKey:"/files",kRequestVerbKey:RequestMethodValue.GET]
        case .local?:
            return [kRequestClassKey:self.classType!,kRequestPlacesKey:self.placesUUID!]
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
        return 20
    }
}
