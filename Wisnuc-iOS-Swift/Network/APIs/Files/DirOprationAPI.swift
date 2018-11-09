//
//  DirOprationAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/3.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

enum FilesOptionType:String{
    case remove
    case rename
}

class DirOprationAPI: BaseRequest {
    var driveUUID:String?
    var directoryUUID:String?
    var name:String?
    var detailUrl:String!
    var op:String?
    init(driveUUID:String,directoryUUID:String,name:String,op:String) {
        self.driveUUID = driveUUID
        self.directoryUUID = directoryUUID
        self.name = name
        self.op = op
        self.detailUrl = "\(kRquestDrivesURL)/\(String(describing: driveUUID))/dirs/\(String(describing: directoryUUID))/entries"
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return RequestHTTPMethod.post
    }

    
    override func requestURL() -> String {
        switch AppNetworkService.networkState {
        case .normal?:
            let requstUrl = "/\(self.detailUrl!)"
//            let dataDic =  [kRequestUrlPathKey:requstUrl,kRequestVerbKey:RequestMethodValue.POST] as [String : Any]
//            guard let data = jsonToData(jsonDic: dataDic as NSDictionary) else {
//                return ""
//            }
//
//            guard let dataString = String.init(data: data, encoding: .utf8) else {
//                return ""
//            }
//
//            guard let urlString = String.init(describing:"\(kCloudBaseURL)\(kCloudCommonJsonUrl)?data=\(dataString)").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
//                return ""
//            }
            
            return kCloudCommonJsonUrl
        case .local?:
            return "/\(self.detailUrl!)"
        default:
            return ""
        }
    }
    
    override func requestEncoding() -> RequestParameterEncoding {
        return JSONEncoding.default
    }
    
    override func requestParameters() -> RequestParameters? {
        switch AppNetworkService.networkState {
        case .normal?:
            let requstUrl = "/\(self.detailUrl!)"
            let param = [kRequestOpKey:op!,kRequestToNameKey:name!]
            return [kRequestUrlPathKey:requstUrl,kRequestVerbKey:RequestMethodValue.POST,kRequestImageParamsKey:param]
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
}
