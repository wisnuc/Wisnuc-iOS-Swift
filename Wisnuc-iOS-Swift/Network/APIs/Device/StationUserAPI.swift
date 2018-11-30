//
//  StationUserAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/28.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

enum StationUserActionType {
    case fetchInfo
    case add
}

class StationUserAPI: BaseRequest {
    var type:StationUserActionType?
    var stationId:String?
    var phone:String?
    init(stationId:String,type:StationUserActionType,phone:String? = nil) {
        self.type = type
        self.stationId = stationId
        self.phone = phone
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
        switch self.type {
        case .fetchInfo?:
            return .get
        case .add?:
            return .post
        default:
            break
        }
        return .get
    }
    
    override func requestParameters() -> RequestParameters? {
        switch self.type {
        case .fetchInfo?:
            return nil
        case .add?:
            guard let phone = self.phone else{
                return nil
            }
            return ["phone":phone]
        default:
            break
        }
        return nil
    }
    
    override func requestEncoding() -> RequestParameterEncoding {
        return self.requestMethod() == .get ? URLEncoding.default : JSONEncoding.default
    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        guard let token = AppUserService.currentUser?.cloudToken else {
            return nil
        }
        return [kRequestAuthorizationKey:token]
    }
}

