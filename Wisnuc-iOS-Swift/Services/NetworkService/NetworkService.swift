//
//  NetworkService.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/30.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

class NetworkService: NSObject {
    var networkState:NetworkServiceState?{
        didSet{
            switch networkState {
            case .normal?:
                networkStateNormalAction()
            case .local?:
                networkStateLocalAction()
            default:
                break
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    func networkStateNormalAction() {
        RequestConfig.sharedInstance.baseURL = kCloudBaseURL
        AppTokenManager.token = AppUserService.currentUser?.cloudToken
    }
    
    func networkStateLocalAction() {
       RequestConfig.sharedInstance.baseURL = AppUserService.currentUser?.localAddr
        AppTokenManager.token = AppUserService.currentUser?.localToken
    }
    
    func checkIP(address:String, _ closure:@escaping (_ success:Bool)->()) {
        let requestURL = "\(address)/station/info"
        let request = Alamofire.request(requestURL).validate().response { (response) in
            if response.error == nil{
                closure(true)
            }else{
                closure(false)
            }
        }
        request.session.configuration.timeoutIntervalForRequest = 3.0
    }
    
    func getLocalInCloudLogin(_ closure:@escaping (( _ error:Error?,_ token:String?)->())){
        if  !AppUserService.isUserLogin {
            return closure(LoginError(code: ErrorCode.Login.NotLogin, kind: LoginError.ErrorKind.LoginFailure, localizedDescription: LocalizedString(forKey: ErrorLocalizedDescription.Login.NotLogin)), nil)
        }
        
        if isNilString( AppUserService.currentUser?.cloudToken){
            return closure(LoginError(code: ErrorCode.Login.NoToken, kind: LoginError.ErrorKind.LoginNoToken, localizedDescription: LocalizedString(forKey: ErrorLocalizedDescription.Login.NoToken)), nil)
        }
        
        LocalTokenInCloudAPI.init().startRequestJSONCompletionHandler({ (response) in
            if response.error != nil{
                let dic = response.value as! NSDictionary
                if dic.value(forKey: "token") != nil{
                    let token =  dic.value(forKey: "token") as! String
                    closure(nil,token)
                }else{
                    closure(LoginError(code: ErrorCode.Login.NoToken, kind: LoginError.ErrorKind.LoginNoToken, localizedDescription: LocalizedString(forKey: ErrorLocalizedDescription.Login.NoToken)),nil)
                }
            }else{
                closure(response.error,nil)
            }
        })
    }
    
    func getUserHome(_ callBack:@escaping (_ error:Error?, _ userHome:String?)->()) {
        if !AppUserService.isUserLogin {
            return callBack(LoginError(code: ErrorCode.Login.NotLogin, kind: LoginError.ErrorKind.LoginFailure, localizedDescription: ErrorLocalizedDescription.Login.NotLogin), nil)
        }
        let isLocalRequest = AppUserService.currentUser?.isLocalLogin?.boolValue
        var find:Bool = false
        DriveAPI.init().startRequestJSONCompletionHandler { (response) in
            if response.error == nil{
                let responseArr = isLocalRequest! ? response.value as! NSArray : (response.value as! NSDictionary).object(forKey: "data") as! NSArray
                responseArr.enumerateObjects({ (obj, idx, stop) in
                    let dic = obj as! NSDictionary
                    if let driveModel = DriveModel.deserialize(from: dic) {
                        if driveModel.tag == "home"{
                            find = true
                            stop.pointee = true
                            return callBack(nil, driveModel.uuid);
                        }
                    }
                })
                
                if !find{
                    return callBack(LoginError.init(code: ErrorCode.Login.NoUserHome, kind: LoginError.ErrorKind.LoginNoUserHome, localizedDescription: ErrorLocalizedDescription.Login.NoUserHome), nil)
                }
            }else{
                return callBack(response.error, nil)
            }
        }
    }
    
    func getUserBackupDir(name:String ,_ callback:@escaping (_ error:Error?,_ entryUUID:String?)->()){
        if !AppUserService.isUserLogin {
            return callback(LoginError(code: ErrorCode.Login.NotLogin, kind: LoginError.ErrorKind.LoginFailure, localizedDescription: ErrorLocalizedDescription.Login.NotLogin), nil)
        }
        
        self.getDirUUID(name: name ,dirUUID: (AppUserService.currentUser?.userHome)!) {[weak self] (getDirUUIDError, directoryUUID) in
            if getDirUUIDError != nil{
                return callback(getDirUUIDError, nil)
            }else{
                saveToUserDefault(value: directoryUUID!, key: kBackupBaseEntryKey)
                // 获取backup 目录 ，如果没有就创建
                // backupBaseDir 就是 “上传的图片” 文件夹 , backupDir 就是 “来自xxx” 文件夹
                let fromName:String = UIDevice.current.modelName
                self?.getDirUUID(name: fromName,dirUUID:directoryUUID!,callBack: { (deviceFromError, deviceFromDirUUID) in
                    if deviceFromError == nil{
                        return callback(deviceFromError,nil)
                    }else{
                        saveToUserDefault(value: directoryUUID!, key: kBackupDirectory)
                        return callback(nil, deviceFromDirUUID);
                    }
                })
            }
        }
    }
    
    // 获取 名为 “上传的照片”（任何name都可以） 的文件夹， 没有就创建
    func getDirUUID(name:String,dirUUID:String,callBack:@escaping ((_ error:Error?,_ directoryUUID:String?)->())) {
        let request = DriveDirAPI.init(driveUUID: (AppUserService.currentUser?.userHome)!, directoryUUID: dirUUID)
        let isLocalRequest = AppUserService.currentUser?.isLocalLogin?.boolValue
        request.startRequestJSONCompletionHandler { (response) in
            if response.error == nil{
                let dic = isLocalRequest! ? response.value as! NSDictionary : (response.value as! NSDictionary).object(forKey: "data") as! NSDictionary
                let arr = NSArray.init(array: dic.object(forKey: "entries") as! NSArray)
                var find:Bool = false
                arr.enumerateObjects({ (obj, idx, stop) in
                    let dic = obj as! NSDictionary
                    if let model = EntriesModel.deserialize(from: dic) {
                        if model.name == name && model.type == "directory" {
                            stop.pointee = true
                            find = true
                            return callBack(nil, model.uuid);
                        }
                    }
                })
                
                if(!find) {
                    let closure = {(_ callBackError:Error?,directoriesModel:DirectoriesModel?)->() in
                        if callBackError != nil {
                           return callBack(callBackError,nil)
                        }else{
                            return callBack(nil,directoriesModel!.uuid)
                        }
                    }
                    
                    self.mkDirIn(dirveUUID: (AppUserService.currentUser?.userHome!)!, directoryUUID: (AppUserService.currentUser?.userHome!)!, name: name, closure: closure)
                }
            }else{
                callBack(response.error,nil)
            }
        }
    }
    
    func mkDirIn(dirveUUID:String,directoryUUID:String,name:String,closure:@escaping (_ callBackError:Error?, _ directoriesModel:DirectoriesModel?)->()) {
        MkdirAPI.init(driveUUID: dirveUUID, directoryUUID: directoryUUID, name: name).startRequestDataCompletionHandler { (response) in
            if response.error == nil{
                do{
                   let directoriesModel = try JSONDecoder().decode(DirectoriesModel.self, from: response.data!)
                   closure(nil,directoriesModel)
                }catch{
                   closure(BaseError(localizedDescription: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail, code: ErrorCode.JsonModel.SwitchTOModelFail),nil)
                }
            }else{
                 closure(response.error,nil)
            }
        }
    }
    
}


