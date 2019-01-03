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
    case changeAuthority
    case delete
}

//获取station下用户
class StationUserAPI: BaseRequest {
    var type:StationUserActionType?
    var stationId:String?
    var phone:String?
    var userId:String?
    var publicSpace:Int?
    
    init(stationId:String,type:StationUserActionType,phone:String? = nil,userId:String? = nil,publicSpace:Int? = nil) {
        self.type = type
        self.stationId = stationId
        self.phone = phone
        self.userId = userId
        self.publicSpace = publicSpace
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
        case .changeAuthority?:
             return .patch
        case .delete?:
            return .delete
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
            guard let phone = self.phone,let publicSpace = self.publicSpace else{
                return nil
            }
            let setting = ["cloud":1,"publicSpace":publicSpace]
            return ["phone":phone,"setting":setting]
        case .changeAuthority?:
            guard let userId = self.userId,let publicSpace = self.publicSpace else{
                return nil
            }
            let setting = ["publicSpace":publicSpace]
            return ["sharedUserId":userId,"setting":setting]
        case .delete?:
            guard let userId = self.userId else {
                return nil
            }
            return ["sharedUserId":userId]
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

