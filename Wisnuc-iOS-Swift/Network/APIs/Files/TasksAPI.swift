//
//  TasksAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/27.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire
enum FilesTaskPolicy:String {
    case skip, keep,replace, rename
}

class TasksAPI: BaseRequest {
    var names:Array<String>?
    var type:String?
    var srcDrive:String?
    var srcDir:String?
    var dstDrive:String?
    var dstDir:String?
    var taskUUID:String?
    var nodeUUID:String?
    var policySameValue:String?
    var policyDiffValue:String?
    var applyToAll:NSNumber?
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
    
    init(taskUUID:String) {
        super.init()
        self.taskUUID = taskUUID
        self.method = RequestHTTPMethod.get
    }
    
    override init() {
        super.init()
        self.method = RequestHTTPMethod.get
    }
    
    init(taskUUID:String,nodeUUID:String,policySameValue:String?,policyDiffValue:String?,applyToAll:Bool? = nil) {
        super.init()
        self.method = RequestHTTPMethod.patch
        self.taskUUID = taskUUID
        self.nodeUUID = nodeUUID
        self.policySameValue = policySameValue
        self.policyDiffValue = policyDiffValue
        self.applyToAll = applyToAll != nil ? NSNumber.init(value: applyToAll!) : nil
    }
    
    override func requestURL() -> String {
        switch AppNetworkService.networkState {
        case .normal?:
            return kCloudCommonJsonUrl
        case .local?:
            return  nodeUUID !=  nil ? "/tasks/\(self.taskUUID!)/nodes/\(self.nodeUUID!)" : taskUUID != nil ? "/tasks/\(self.taskUUID!)" : "/tasks"
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
            let urlPath = nodeUUID !=  nil ? "/tasks/\(self.taskUUID!)/nodes/\(self.nodeUUID!)" : taskUUID != nil ? "/tasks/\(self.taskUUID!)" : "/tasks"
            if self.method == RequestHTTPMethod.post{
                let src = [kRequestTaskDriveKey:srcDrive!,kRequestTaskDirKey:srcDir!]
                let dst = [kRequestTaskDriveKey:dstDrive!,kRequestTaskDirKey:dstDir!]
                let params = [kRequestTaskTypeKey:type!,kRequestTaskSrcKey:src,kRequestTaskDstKey:dst,kRequestEntriesValueKey:names!] as [String : Any]
                let dic = [kRequestVerbKey:RequestMethodValue.POST,kRequestUrlPathKey:urlPath,kRequestImageParamsKey:params] as [String : Any]
                return dic
            }else if self.method == RequestHTTPMethod.patch{
                let params = [kRequestTaskPolicyKey:[policySameValue != nil ? policySameValue : nil ,policyDiffValue != nil ? policyDiffValue! : nil], "applyToAll" : applyToAll ?? NSNumber.init(value: false)] as [String : Any]
                let dic = [kRequestVerbKey:RequestMethodValue.PATCH,kRequestUrlPathKey:urlPath,kRequestImageParamsKey:params] as [String : Any]
                return dic
            }else{
                return nil
            }
        case .local?:
            if self.method == RequestHTTPMethod.post{
                let src = [kRequestTaskDriveKey:srcDrive!,kRequestTaskDirKey:srcDir!]
                let dst = [kRequestTaskDriveKey:dstDrive!,kRequestTaskDirKey:dstDir!]
                let dic = [kRequestTaskTypeKey:type!,kRequestTaskSrcKey:src,kRequestTaskDstKey:dst,kRequestEntriesValueKey:names!] as [String : Any]
                return dic
            }else if self.method == RequestHTTPMethod.patch{
                let dic = [kRequestTaskPolicyKey:[policySameValue != nil ? policySameValue : nil ,policyDiffValue != nil ? policyDiffValue! : nil], "applyToAll" : applyToAll ?? NSNumber.init(value: false)] as [String : Any]
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
