//
//  TasksAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/27.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire
enum FilesTasksType:String{
    case copy
    case move
    case icopy
    case imove
    case ecopy
    case emove
    case ncopy
    case nmove
}

class TasksAPI: BaseRequest {
    var names:Array<String>?
    var type:String?
    var srcDrive:String?
    var srcDir:String?
    var dstDrive:String?
    var dstDir:String?
    
    init(type:String,names:Array<String>,srcDrive:String,srcDir:String,dstDrive:String,dstDir:String) {
        super.init()
        self.type = type
        self.names = names
        self.srcDrive = srcDrive
        self.srcDir = srcDir
        self.dstDrive = dstDrive
        self.dstDir = dstDir
    }
    
    override func requestURL() -> String {
        switch AppNetworkService.networkState {
        case .normal?:
            return kCloudCommonJsonUrl
        case .local?:
            return "/tasks"
        default:
            return ""
        }
    }
    
    override func requestMethod() -> RequestHTTPMethod {
        return RequestHTTPMethod.post
    }
    
    override func requestParameters() -> RequestParameters? {
        switch AppNetworkService.networkState {
        case .normal?:
            return RequestParameters.init()
        case .local?:
            let src = [kRequestTaskDriveKey:srcDrive!,kRequestTaskDirKey:srcDir!]
            let dst = [kRequestTaskDriveKey:dstDrive!,kRequestTaskDirKey:dstDir!]
            let dic = [kRequestTaskTypeKey:type!,kRequestTaskSrcKey:src,kRequestTaskDstKey:dst,kRequestEntriesValueKey:names!] as [String : Any]
            return dic
        default:
            return RequestParameters.init()
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
    
    override func requestEncoding() -> RequestParameterEncoding {
        return  JSONEncoding.default
    }
}
