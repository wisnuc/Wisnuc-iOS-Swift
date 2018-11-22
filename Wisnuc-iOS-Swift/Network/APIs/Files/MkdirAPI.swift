//
//  MkdirAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/4.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

class MkdirAPI: BaseRequest {
    var driveUUID:String?
    var directoryUUID:String?
    var name:String?
    var detailUrl:String!
    init(driveUUID:String,directoryUUID:String,name:String? = nil) {
        self.driveUUID = driveUUID
        self.directoryUUID = directoryUUID
        self.name = name
        self.detailUrl = "\(kRquestDrivesURL)/\(String(describing: driveUUID))/dirs/\(String(describing: directoryUUID))/entries"
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return RequestHTTPMethod.post
    }
    
    override func requestEncoding() -> RequestParameterEncoding {
        return  requestMethod() == RequestHTTPMethod.get ? URLEncoding.default : JSONEncoding.default
    }
    
    override func requestURL() -> String {
        switch AppNetworkService.networkState {
        case .normal?:
            guard let url = detailUrl else{
                return ""
            }
            let requstUrl = "/\(url)"
            let dataDic =  [kRequestUrlPathKey:requstUrl,kRequestVerbKey:RequestMethodValue.POST] as [String : Any]
            guard let data = jsonToData(jsonDic: dataDic as NSDictionary) else {
                return ""
            }
            
            guard let dataString = String.init(data: data, encoding: .utf8) else {
                return ""
            }
            
            guard let urlString = String.init(describing:"\(kCloudBaseURL)\(kCloudCommonPipeUrl)?data=\(dataString)").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
                return ""
            }
            
            return urlString
        case .local?:
            return "/\(self.detailUrl!)"
        default:
            return ""
        }
    }
    
//    override func requestParameters() -> RequestParameters? {
//        switch AppNetworkService.networkState {
//        case .normal?:
//            guard let detailUrl = self.detailUrl else{
//                return nil
//            }
//            
//            guard let name = self.name else{
//                return nil
//            }
//            let params = [kRequestOpKey:kRequestMkdirValue,kRequestToNameKey:name]
//            return [kRequestUrlPathKey:"/\(detailUrl)",kRequestVerbKey:RequestMethodValue.POST,kRequestImageParamsKey:params]
//        case .local?:
//           return nil
//        default:
//            return nil
//        }
//    }
    
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
