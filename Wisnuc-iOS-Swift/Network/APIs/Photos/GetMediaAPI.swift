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
    var types:String?
    init(classType:String? = nil,placesUUID:String,types:String? = nil) {
        self.classType = classType
        self.placesUUID = placesUUID
        self.types = types
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
        guard let placesUUID = self.placesUUID else {
            return nil
        }
        switch AppNetworkService.networkState {
        case .normal?:
            let urlPath = "/files"
            var params = [String:String]()
            if let classType = self.classType{
               params  = [kRequestClassKey:classType,kRequestPlacesKey:placesUUID]
            }
            if let types = self.types{
                params  = [kRequestTypesKey:types,kRequestPlacesKey:placesUUID]
            }
            return [kRequestUrlPathKey:urlPath,kRequestVerbKey:RequestMethodValue.GET,kRequestImageParamsKey:params as Dictionary<String,String>]
        case .local?:
            var params:[String:String]?
            if let classType = self.classType{
                params  = [kRequestClassKey:classType,kRequestPlacesKey:placesUUID]
            }
            if let types = self.types{
                params  = [kRequestTypesKey:types,kRequestPlacesKey:placesUUID]
            }
            return params
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
    
    override func timeoutIntervalForRequest() -> TimeInterval {
        return 20
    }
}
