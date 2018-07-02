
//
//  DeletTasksAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/2.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation

class DeletTasksAPI: BaseRequest {
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
        return  RequestHTTPMethod.delete
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
