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
    var method:RequestHTTPMethod?
    
    init(type:String,names:Array<String>,srcDrive:String,srcDir:String,dstDrive:String,dstDir:String) {
        super.init()
        self.type = type
        self.names = names
        self.srcDrive = srcDrive
        self.srcDir = srcDir
        self.dstDrive = dstDrive
        self.dstDir = dstDir
        self.method = RequestHTTPMethod.post
    }
    
    override init() {
        super.init()
        self.method = RequestHTTPMethod.get
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
        return  self.method ?? RequestHTTPMethod.get
    }
    
    override func requestParameters() -> RequestParameters? {
        switch AppNetworkService.networkState {
        case .normal?:
            return nil
        case .local?:
            if self.method != RequestHTTPMethod.get{
                let src = [kRequestTaskDriveKey:srcDrive!,kRequestTaskDirKey:srcDir!]
                let dst = [kRequestTaskDriveKey:dstDrive!,kRequestTaskDirKey:dstDir!]
                let dic = [kRequestTaskTypeKey:type!,kRequestTaskSrcKey:src,kRequestTaskDstKey:dst,kRequestEntriesValueKey:names!] as [String : Any]
                return dic
            }else{
                return nil
            }
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
    
    override func requestEncoding() -> RequestParameterEncoding {
        return  self.method == RequestHTTPMethod.get ? URLEncoding.default : JSONEncoding.default
    }
}
