//
//  WechatActionAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/30.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire
enum WechatActionType {
    case bind
    case unbind
}

class WechatActionAPI: BaseRequest {
    var type:WechatActionType?
    var code:String?
    var unionid:String?
    init(type:WechatActionType,code:String? = nil,unionid:String? = nil) {
        self.type = type
        self.code = code
        self.unionid = unionid
    }
    
    override func requestURL() -> String {
        return "/user/wechat"
    }
    
    override func baseURL() -> String {
        return kCloudBaseURL
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        switch type {
        case .bind?:
            return  RequestHTTPMethod.post
        case .unbind?:
            return  RequestHTTPMethod.delete
        default:
            break
        }
        return  RequestHTTPMethod.get
    }
    
    override func requestEncoding() -> RequestParameterEncoding {
        return JSONEncoding.default
    }
    
    override func requestParameters() -> RequestParameters? {
        switch type {
        case .bind?:
            if let code = self.code{
                return  ["code":code,"type":"mobile"]
            }
        case .unbind?:
            if let unionid = self.unionid{
                return  ["unionid":unionid]
            }
        default:
            break
        }
        return  nil
    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        guard let token = AppUserService.currentUser?.cloudToken else {
            return nil
        }
        
        let params =  [kRequestAuthorizationKey:token]
        return params
    }
}
