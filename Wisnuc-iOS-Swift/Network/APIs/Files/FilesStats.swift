//
//  FilesStats.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/26.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

class FilesStats: BaseRequest {
    var driveUUID:String?
    var directoryUUID:String?
    var detailUrl:String!
    init(driveUUID:String,directoryUUID:String) {
        self.driveUUID = driveUUID
        self.directoryUUID = directoryUUID
        self.detailUrl = "\(kRquestDrivesURL)/\(String(describing: driveUUID))/dirs/\(String(describing: directoryUUID))/stats"
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        switch AppNetworkService.networkState {
        case .normal?:
              return RequestHTTPMethod.post
        case .local?:
              return RequestHTTPMethod.get
        default:
            return RequestHTTPMethod.get
        }
    }
    
    override func requestEncoding() -> RequestParameterEncoding {
        return  requestMethod() == RequestHTTPMethod.get ? URLEncoding.default : JSONEncoding.default
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
                guard let detailUrl = self.detailUrl else{
                    return nil
                }
                return [kRequestUrlPathKey:"/\(detailUrl)",kRequestVerbKey:RequestMethodValue.GET]
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
