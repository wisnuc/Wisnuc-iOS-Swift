//
//  DriveAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/31.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire
enum  DrivesAPIType {
    case fetchInfo
    case creatBackup
    case creatPublic
}

class DriveAPI: BaseRequest {
    var type:DrivesAPIType?
    var ouser:User?
    init(type:DrivesAPIType,user:User? = nil) {
        self.type = type
        if user != nil{
            self.ouser = user
        }
    }
    
    override func baseURL() -> String {
        switch AppNetworkService.networkState {
        case .normal?:
            return  kCloudBaseURL
        case .local?:
            if let user = self.ouser{
                if let addr = user.localAddr{
                    return addr
                }
            }
            if let addr = AppUserService.currentUser?.localAddr{
                return addr
            }
            return  ""
        default:
            return ""
        }
    }
    
    override func requestURL() -> String {
        switch AppNetworkService.networkState {
        case .normal?:
            if let user = self.ouser{
                if let stationId = user.stationId{
                    return "/station/\(stationId)/json"
                }
            }
            return kCloudCommonJsonUrl
        case .local?:
            return "/\(kRquestDrivesURL)"
        default:
            return ""
        }
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        switch AppNetworkService.networkState {
        case .normal?:
            return .post
        case .local?:
            switch self.type {
            case .fetchInfo?:
                return .get
            case .creatBackup?,.creatPublic?:
                return .post
            default:
                return .post
            }
        default:
            return .get
        }
    }
    
    override func requestParameters() -> RequestParameters? {
        switch AppNetworkService.networkState {
        case .normal?:
            switch self.type {
            case .fetchInfo?:
                let urlPath = "/\(kRquestDrivesURL)"
                return [kRequestVerbKey:RequestMethodValue.GET,kRequestUrlPathKey:urlPath]
            case .creatBackup?:
                let urlPath = "/\(kRquestDrivesURL)"
                guard let unicode = getUniqueDevice() else{
                   return nil
                }
                let client = [ "id": unicode,"type": kBackupClientType]
                let params = [kRequestOpKey:"backup",kRequestLabelKey:UIDevice.current.modelName,kRequestClientKey:client] as [String : Any]
                return [kRequestVerbKey:RequestMethodValue.POST,kRequestUrlPathKey:urlPath,kRequestImageParamsKey:params]
            default:
                return nil
            }
          
        case .local?:
            switch self.type {
            case .creatBackup?:
                guard let unicode = getUniqueDevice() else{
                    return nil
                }
                let client = [ "id": unicode,"type": kBackupClientType]
                let params = [kRequestOpKey:"backup",kRequestLabelKey:UIDevice.current.modelName,kRequestClientKey:client] as [String : Any]
                return params
            default:
                return nil
            }
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
            if let user = self.ouser{
                if let token = user.cloudToken,let cookie = user.cookie{
                    return [kRequestAuthorizationKey:token,kRequestSetCookieKey:cookie]
                }
            }
            if let token = AppUserService.currentUser?.cloudToken{
               return [kRequestAuthorizationKey:token,kRequestSetCookieKey:AppUserService.currentUser?.cookie ?? ""]
            }
             return nil
        case .local?:
            if let user = self.ouser{
                if let token = user.localToken{
                    return [kRequestAuthorizationKey:JWTTokenString(token:token)]
                }
            }
            if let token = AppUserService.currentUser?.localToken{
                return [kRequestAuthorizationKey:JWTTokenString(token:token)]
            }
            return nil
        default:
            return nil
        }
    }
}
