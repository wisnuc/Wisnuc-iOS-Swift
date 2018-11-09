//
//  GetMediaAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/23.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

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
            let urlPath = "/files"
            let params  = [kRequestClassKey:self.classType!,kRequestPlacesKey:self.placesUUID!]
            return [kRequestUrlPathKey:urlPath,kRequestVerbKey:RequestMethodValue.GET,kRequestImageParamsKey:params as Dictionary<String,String>]
        case .local?:
            return [kRequestClassKey:self.classType!,kRequestPlacesKey:self.placesUUID!]
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
