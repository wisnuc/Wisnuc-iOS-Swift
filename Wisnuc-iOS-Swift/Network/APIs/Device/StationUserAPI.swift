//
//  StationUserAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/28.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class StationUserAPI: BaseRequest {
    var stationId:String?
    init(stationId:String) {
        self.stationId = stationId
    }
    
    override func requestURL() -> String {
        guard let stationId = self.stationId else {
            return ""
        }
        return "/station/\(stationId)/user"
    }
    
    override func baseURL() -> String {
        return kCloudBaseURL
    }
    
    
    override func requestMethod() -> RequestHTTPMethod {
        return .get
    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        guard let token = AppUserService.currentUser?.cloudToken else {
            return nil
        }
        return [kRequestAuthorizationKey:token]
    }
}

