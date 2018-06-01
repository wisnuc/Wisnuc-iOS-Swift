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
    
    func getUserBackupDirName(name:String ,_ callback:(_ error:Error?,_ entryUUID:String?)->()){
        if !AppUserService.isUserLogin {
            return callback(LoginError(code: ErrorCode.Login.NotLogin, kind: LoginError.ErrorKind.LoginFailure, localizedDescription: ErrorLocalizedDescription.Login.NotLogin), nil)
        }

//        [self getUserBackupDirName:name BaseDir:^(NSError *error, NSString *dirUUID) {
//        if(error) return callback(error, NULL);
//        SaveToUserDefault(Current_Backup_Base_Entry, dirUUID);
//        [self getUserBackupDirWithBackUpBaseDir:dirUUID complete:^(NSError *err, NSString *backupDirUUID) {
//        if(err) return callback(err, NULL);
//        SaveToUserDefault(Current_Backup_Dir, backupDirUUID);
//        return callback(nil, backupDirUUID);
//        }];
//        }];
    }
    
    
}


