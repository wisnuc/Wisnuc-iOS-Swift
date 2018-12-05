//
//  UserDeviceInfoAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/12/5.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

class UserDeviceInfoAPI: BaseRequest {
    var sn:String?
    var cloudToken:String?
    
    init(sn:String,token:String) {
        super.init()
        self.sn = sn
        self.cloudToken = token
    }
    
    override func baseURL() -> String {
        return kCloudBaseURL
    }
    
    override func requestURL() -> String {
        return "/user/deviceInfo"
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return .post
    }
    
    override func requestEncoding() -> RequestParameterEncoding {
        return JSONEncoding.default
    }
    
    override func requestParameters() -> RequestParameters? {
        if let sn = self.sn{
            return ["sn":sn]
        }
        return nil
    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        if let token = cloudToken{
            let dic = [kRequestAuthorizationKey:token]
            return dic
        }
      return nil
    }
}
