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
    var metadata:Bool?
    init(classType:String? = nil,placesUUID:String,types:String? = nil,metadata:Bool? = nil) {
        self.classType = classType
        self.placesUUID = placesUUID
        self.types = types
        self.metadata = metadata
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
            var params = [String:Any]()
            if let classType = self.classType{
               params  = [kRequestClassKey:classType,kRequestPlacesKey:placesUUID,"order":SearhOrder.newest.rawValue]
//                if let metadata = self.metadata{
//                    if  metadata{
//                        params["metadata"] = true
//                    }
//                }
            }
            if let types = self.types{
                params  = [kRequestTypesKey:types,kRequestPlacesKey:placesUUID,"order":SearhOrder.newest.rawValue]
//                if let metadata = self.metadata{
//                    if  metadata{
//                        params["metadata"] = true
//                    }
//                }
            }
            return [kRequestUrlPathKey:urlPath,kRequestVerbKey:RequestMethodValue.GET,kRequestImageParamsKey:params]
        case .local?:
            var params:[String:Any]?
            if let classType = self.classType{
                params  = [kRequestClassKey:classType,kRequestPlacesKey:placesUUID,"order":SearhOrder.newest.rawValue]
//                if let metadata = self.metadata{
//                    if  metadata{
//                        params?["metadata"] = true
//                    }
//                }
            }
            if let types = self.types{
                params  = [kRequestTypesKey:types,kRequestPlacesKey:placesUUID,"order":SearhOrder.newest.rawValue]
//                if let metadata = self.metadata{
//                    if  metadata{
//                        params?["metadata"] = true
//                    }
//                }
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
            if let token = AppUserService.currentUser?.cloudToken,let cookie = AppUserService.currentUser?.cookie{
                let header =  [kRequestAuthorizationKey:token,kRequestSetCookieKey:cookie]
                return header
            }
            return nil
        case .local?:
            if let token = AppUserService.currentUser?.localToken{
                let header = [kRequestAuthorizationKey:JWTTokenString(token: token)]
                return header
            }
            return nil
        default:
            return nil
        }
    }
    
    override func timeoutIntervalForRequest() -> TimeInterval {
        return 20
    }
}
