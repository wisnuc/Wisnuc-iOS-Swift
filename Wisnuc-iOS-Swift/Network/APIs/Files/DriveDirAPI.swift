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
    
    override func requestParameters() -> RequestParameters? {
        switch AppNetworkService.networkState {
        case .normal?:
            let resource = "\(kRquestDrivesURL)/\(String(describing: self.driveUUID!))/dirs/\(String(describing: self.directoryUUID!))"
            let dic = [kRequestMethodKey:RequestMethodValue.GET,kRequestResourceKey:resource.toBase64()]
            return dic
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
    
    override func timeoutIntervalForRequest() -> TimeInterval {
        return 15.0
    }
}
