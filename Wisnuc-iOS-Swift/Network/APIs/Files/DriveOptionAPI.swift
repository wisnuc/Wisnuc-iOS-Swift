//
//  DriveOptionAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/12/11.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

enum  DriveOptionAPIType {
    case fetchInfo
    case update
    case delete
}

//Drive 操作API
class DriveOptionAPI: BaseRequest {
    var type:DriveOptionAPIType?
    var drive:String?
    
    init(drive:String,type:DriveOptionAPIType) {
        self.drive = drive
        self.type = type
    }
    
    override func requestURL() -> String {
        switch AppNetworkService.networkState {
        case .normal?:
            return kCloudCommonJsonUrl
        case .local?:
            if let drive = self.drive{
                return "/\(kRquestDrivesURL)/\(drive)"
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
            switch self.type {
            case .fetchInfo?:
                return .get
            case .update?:
                return .patch
            case .delete?:
                return .delete
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
                if let drive = self.drive{
                    let urlPath = "/\(kRquestDrivesURL)/\(drive)"
                    return [kRequestVerbKey:RequestMethodValue.GET,kRequestUrlPathKey:urlPath]
                }
            case .update?:
                let urlPath = "/\(kRquestDrivesURL)"
                guard let unicode = getUniqueDevice() else{
                    return nil
                }
                let client = [ "id": unicode,"type": kBackupClientType]
                let params = [kRequestOpKey:"backup",kRequestLabelKey:UIDevice.current.modelName,kRequestClientKey:client] as [String : Any]
                return [kRequestVerbKey:RequestMethodValue.PATCH,kRequestUrlPathKey:urlPath,kRequestImageParamsKey:params]
            case .delete?:
                guard  let drive = self.drive else{
                    return nil
                }
                let urlPath = "/\(kRquestDrivesURL)/\(drive)"
                let params = [kRequestOpKey:"backup"]
                return [kRequestVerbKey:RequestMethodValue.DELETE,kRequestUrlPathKey:urlPath,kRequestImageParamsKey:params]
            default:
                return nil
            }
            
        case .local?:
            switch self.type {
            case .delete?:
                let params = [kRequestOpKey:"backup"]
                return params
            default:
                return nil
            }
        default:
            return nil
        }
        return nil
    }
    
    override func requestEncoding() -> RequestParameterEncoding {
        return  requestMethod() == RequestHTTPMethod.get ? URLEncoding.default : JSONEncoding.default
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
