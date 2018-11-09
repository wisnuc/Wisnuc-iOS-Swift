//
//  DriveDirAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/4.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

class DriveDirAPI: BaseRequest {
    var driveUUID:String?
    var directoryUUID:String?
    init(driveUUID:String,directoryUUID:String) {
        self.driveUUID = driveUUID
        self.directoryUUID = directoryUUID
    }
    
    override func requestURL() -> String {
        switch AppNetworkService.networkState {
        case .normal?:
            return kCloudCommonJsonUrl
        case .local?:
            return  "/\(kRquestDrivesURL)/\(String(describing: self.driveUUID!))/dirs/\(String(describing: self.directoryUUID!))"
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
            let urlPath = "/\(kRquestDrivesURL)/\(String(describing: self.driveUUID!))/dirs/\(String(describing: self.directoryUUID!))"
            let dic = [kRequestVerbKey:RequestMethodValue.GET,kRequestUrlPathKey:urlPath]
            return dic
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
        switch AppNetworkService.networkState {
        case .normal?:
            return [kRequestAuthorizationKey:AppTokenManager.token ?? ""]
        case .local?:
            return [kRequestAuthorizationKey:JWTTokenString(token: AppTokenManager.token ?? "")]
        default:
            return nil
        }
    }
    
    override func timeoutIntervalForRequest() -> TimeInterval {
        return 15.0
    }
}
