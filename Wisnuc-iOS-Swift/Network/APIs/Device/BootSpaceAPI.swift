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
    var stationId:String?
    var address:String?
    override init() {
        
    }
    
    init(stationId:String,address:String? = nil){
        self.stationId = stationId
        self.address = address
    }
    
    override func baseURL() -> String {
        if self.stationId != nil && self.address == nil{
             return kCloudBaseURL
        }
        switch AppNetworkService.networkState {
        case .normal?:
                return kCloudBaseURL
        case .local?:
            if let address = self.address{
                return "http://\(address):3000"
            }
            return AppUserService.currentUser?.localAddr ?? ""
        default:
            return ""
        }
    }
    
    override func requestURL() -> String {
        if self.stationId != nil && self.address == nil{
            return "/station/\(String(describing: self.stationId!))/json"
        }
        switch AppNetworkService.networkState {
        case .normal?:
            if let stationId = self.stationId{
               return "/station/\(String(describing: stationId))/json"
            }
            return "/station/\(String(describing: AppUserService.currentUser?.stationId ?? ""))/json"
        case .local?:
            return "/boot/space"
        default:
            return ""
        }
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        if self.stationId != nil && self.address == nil{
            return .post
        }
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
        if self.stationId != nil && self.address == nil{
            let urlPath = "/boot/space"
            return [kRequestVerbKey:RequestMethodValue.GET,kRequestUrlPathKey:urlPath]
        }
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
        if self.stationId != nil && self.address == nil{
            return [kRequestAuthorizationKey:AppTokenManager.token!,kRequestSetCookieKey:AppUserService.currentUser?.cookie ?? ""]
        }
        switch AppNetworkService.networkState {
        case .normal?:
            if let token = AppUserService.currentUser?.cloudToken{
                return  [kRequestAuthorizationKey:token,kRequestSetCookieKey:AppUserService.currentUser?.cookie ?? ""]
            }
            return nil
        case .local?:
            return [kRequestAuthorizationKey:JWTTokenString(token: AppTokenManager.token!)]
        default:
            return nil
        }
    }
}
