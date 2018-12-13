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
    init(type:DrivesAPIType) {
        self.type = type
    }
    
    override func requestURL() -> String {
        switch AppNetworkService.networkState {
        case .normal?:
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
            if let token = AppUserService.currentUser?.cloudToken{
               return [kRequestAuthorizationKey:token,kRequestSetCookieKey:AppUserService.currentUser?.cookie ?? ""]
            }
             return nil
        case .local?:
            return [kRequestAuthorizationKey:JWTTokenString(token: AppTokenManager.token!)]
        default:
            return nil
        }
    }
}
