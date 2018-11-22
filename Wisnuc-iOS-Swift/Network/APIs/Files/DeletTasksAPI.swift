
//
//  DeletTasksAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/2.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import Alamofire

class DeleteTasksAPI: BaseRequest {
    var taskUUID:String?
    
    init(taskUUID:String) {
        super.init()
        self.taskUUID = taskUUID
    }
    override func requestURL() -> String {
        switch AppNetworkService.networkState {
        case .normal?:
            return kCloudCommonJsonUrl
        case .local?:
            return "/tasks/\(taskUUID!)"
        default:
            return ""
        }
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        switch AppNetworkService.networkState {
        case .normal?:
            return RequestHTTPMethod.post
        case .local?:
            return RequestHTTPMethod.delete
        default:
            return RequestHTTPMethod.get
        }
    }
    
    override func requestEncoding() -> RequestParameterEncoding {
        return JSONEncoding.default
    }
    
    override func requestParameters() -> RequestParameters? {
        switch AppNetworkService.networkState {
        case .normal?:
            guard let uuid = self.taskUUID else{
              return nil
            }
            let urlPath =  "/tasks/\(uuid)"
            let params = [kRequestVerbKey:RequestMethodValue.DELETE,kRequestUrlPathKey:urlPath]
            return params
        case .local?:
            return nil
        default:
            return nil
        }
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
}
