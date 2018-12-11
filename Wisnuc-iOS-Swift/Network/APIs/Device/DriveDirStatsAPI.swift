//
//  DriveDirStatsAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/12/11.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class DriveDirStatsAPI: BaseRequest {
    var drive:String?
    var dir:String?
    init(drive:String,dir:String) {
        self.drive = drive
        self.dir = dir
    }
    
    override func requestURL() -> String {
        switch AppNetworkService.networkState {
        case .normal?:
            return kCloudCommonJsonUrl
        case .local?:
            if let dirve = self.drive,let dir = self.dir{
               let urlPath = "/\(kRquestDrivesURL)/\(dirve)/dirs/\(dir)/stats"
               return urlPath
            }
           return ""
        default:
            return ""
        }
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
    
    override func requestParameters() -> RequestParameters? {
        switch AppNetworkService.networkState {
        case .normal?:
            if let dirve = self.drive,let dir = self.dir{
                let urlPath = "/\(kRquestDrivesURL)/\(dirve)/dirs/\(dir)/stats"
                return [kRequestVerbKey:RequestMethodValue.GET,kRequestUrlPathKey:urlPath]
            }
            return nil
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
