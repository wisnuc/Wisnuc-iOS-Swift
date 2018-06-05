//
//  UsersInfoAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/5.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class UsersInfoAPI: BaseRequest {
    var method:String?
    var disabled:Bool?
    var isAdmin:Bool?
    var uuid:String?
    
    init(method:String,disabled:Bool,uuid:String?) {
        self.method = method
        self.disabled = disabled
        self.uuid = uuid
    }
    
    init(method:String,isAdmin:Bool,uuid:String?) {
        self.method = method
        self.isAdmin = isAdmin
        self.uuid = uuid
    }
    
    override init() {
        
    }
    
    override func requestURL() -> String {
        var resource = ""
        if !isNilString(uuid) {
            resource  = "users/\(String(describing: uuid!)))"
        }else{
            resource = "users/\(String(describing: (AppUserService.currentUser?.uuid!)!))"
        }
        
        switch AppNetworkService.networkState {
        case .normal?:
            return "\(kCloudCommonJsonUrl)?resource=\(resource)&method=\(RequestMethodValue.GET)"
        case .local?:
            return "/\(resource)"
        default:
            return ""
        }
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        if method != nil{
            return RequestHTTPMethod(rawValue: method!)!
        }else{
            return RequestHTTPMethod.get
        }
    }
    
    override func requestParameters() -> RequestParameters? {
        var requestParameters:RequestParameters?
        if disabled != nil {
            requestParameters = ["disabled":disabled!]
        }
        
        if isAdmin != nil {
            requestParameters = ["isAdmin":isAdmin!]
        }
        return requestParameters
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
}
