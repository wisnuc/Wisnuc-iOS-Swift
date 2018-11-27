

//
//  NicknameAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/27.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

class NicknameAPI: BaseRequest {
    var nickname:String?
    init(nickname:String) {
        self.nickname = nickname
    }
    
    override func requestURL() -> String {
        return "/user/nickname"
    }
    
    override func baseURL() -> String {
        return kCloudBaseURL
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return  RequestHTTPMethod.patch
    }
    
    override func requestParameters() -> RequestParameters? {
        if let nickname = self.nickname{
            return ["nickName":nickname]
        }
        return nil
    }
    
    override func requestEncoding() -> RequestParameterEncoding {
        return  JSONEncoding.default
    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        guard let token = AppUserService.currentUser?.cloudToken else {
            return nil
        }
        
        let params =  [kRequestAuthorizationKey:token]
        return params
    }
}
