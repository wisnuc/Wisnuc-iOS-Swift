//
//  DirOprationAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/3.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
enum FilesOptionType:String{
    case remove
}

class DirOprationAPI: BaseRequest {
    var driveUUID:String?
    var directoryUUID:String?
    var name:String?
    var detailUrl:String!
    var op:String?
    init(driveUUID:String,directoryUUID:String,name:String,op:String) {
        self.driveUUID = driveUUID
        self.directoryUUID = directoryUUID
        self.name = name
        self.op = op
        self.detailUrl = "\(kRquestDrivesURL)/\(String(describing: driveUUID))/dirs/\(String(describing: directoryUUID))/entries"
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return RequestHTTPMethod.post
    }
    
    override func requestURL() -> String {
        switch AppNetworkService.networkState {
        case .normal?:
            return kCloudCommonJsonUrl
        case .local?:
            return "/\(self.detailUrl!)"
        default:
            return ""
        }
    }
    
    override func requestParameters() -> RequestParameters? {
        switch AppNetworkService.networkState {
        case .normal?:
            return [kRequestResourceKey:detailUrl.toBase64(),kRequestMethodKey:RequestMethodValue.POST,kRequestOpKey:op!,kRequestToNameKey:name!]
        case .local?:
            return nil
        default:
            return nil
        }
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
