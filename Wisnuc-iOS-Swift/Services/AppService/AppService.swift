 //
//  AppService.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/23.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MDCAlertController

let MainServices = AppService.sharedInstance
let AppUserService =  MainServices().userService
let AppNetworkService =  MainServices().networkService
let AppAssetService =  MainServices().assetService
let AppDBService =  MainServices().dbService
let AppTokenManager =  MainServices().tokenManager

class AppService: NSObject,ServiceProtocol{
    private var isRebuildingAutoBackupManager = false
    private static var privateShared : AppService?
    class func sharedInstance() -> AppService { // change class to final to prevent override
        guard let uwShared = privateShared else {
            privateShared = AppService()
            return privateShared!
        }
        return uwShared
    }
    
    override init() {
        super.init()
        isStartingUpload = false
        if self.assetService.userAuth! {
//            self.autoBackupManager.start(localAssets: self.assetService.allAssets!, netAssets: [EntriesModel]())
        }
    }
    
    func abort() {
        NetEngine.sharedInstance.cancleAllRequest()
        userService.abort()
        print("Disposed Singleton instance")
    }
    
    deinit {
    }
    
    func loginAction(model:CloadLoginUserRemotModel,url:String,basicAuth:String,complete:@escaping ((_ error:Error?,_ user:User?)->())){
        if model.uuid == nil || isNilString(model.uuid){
            complete(LoginError(code: ErrorCode.Login.NoUUID, kind: LoginError.ErrorKind.LoginNoUUID, localizedDescription: LocalizedString(forKey: "UUID is not exist")), nil)
        }
        
        let callBackClosure = { (callBackError:Error? , callBackUser:User?)->() in
            complete(callBackError,callBackUser)
        }
        LocalLoginTokenAPI.init(url: url, auth: basicAuth).startRequestJSONCompletionHandler { [weak self](response) in
            if response.error == nil {
                ActivityIndicator.stopActivityIndicatorAnimation()
                let token = (response.result.value as! NSDictionary)["token"] as! String
                let user = AppUserService.createUser(uuid: model.uuid!)
                user.userName = model.username!
                user.localAddr = url
                user.localToken = token
                user.isFirstUser = NSNumber.init(value: model.isFirstUser ?? Int(truncating: false))
                user.isAdmin = NSNumber.init(value: model.isAdmin ?? Int(truncating: false))
                user.isLocalLogin = false
                user.bonjour_name = model.name
                self?.userService.setCurrentUser(user)
                self?.userService.synchronizedCurrentUser()
                AppNetworkService.networkState = .local
                self?.nextStepForLogin(callback: callBackClosure)
            }else{
                if response.data != nil {
                    let errorDict =  dataToNSDictionary(data: response.data!)
                    if errorDict != nil{
                        Message.message(text: errorDict!["message"] != nil ? errorDict!["message"] as! String :  (response.error?.localizedDescription)!)
                    }else{
                        let backToString = String(data: response.data!, encoding: String.Encoding.utf8) as String?
                        print(backToString ?? "ddd")
                    }
                }
                callBackClosure(response.error,nil)
            }
        }
    }
    
    func loginAction(model:CloadLoginUserRemotModel,orginTokenUser:User,complete:@escaping ((_ error:Error?,_ user:User?)->())){
        if model.uuid == nil || isNilString(model.uuid){
            complete(LoginError(code: ErrorCode.Login.NoUUID, kind: LoginError.ErrorKind.LoginNoUUID, localizedDescription: LocalizedString(forKey: "UUID is not exist")), nil)
        }
        
        let callBackClosure = { (callBackError:Error? , callBackUser:User?)->() in
            complete(callBackError,callBackUser)
        }

        let user = AppUserService.createUser(uuid: model.uuid!)
        user.userName = model.username
        user.bonjour_name = model.name
        user.stationId = model.id
        user.cloudToken = orginTokenUser.cloudToken
        user.isFirstUser = NSNumber.init(value: model.isFirstUser!)
        user.isAdmin = NSNumber.init(value: model.isAdmin!)
        user.avaterURL = orginTokenUser.avaterURL
        user.isLocalLogin = NSNumber.init(value: false)

        if !isNilString(model.LANIP) {
            let urlString  = "http://\(String(describing: model.LANIP!)):3000"
            user.localAddr = urlString
        }
        self.userService.setCurrentUser(user)
        self.userService.synchronizedCurrentUser()
        if user.localAddr != nil{
            networkService.checkIP(address: user.localAddr!) { [weak self] (success) in
                if success{
                    self?.networkService.getLocalInCloudLogin({ [weak self](localTokenError, localToken) in
                        if localTokenError == nil{
                            user.isLocalLogin = NSNumber.init(value: true)
                            user.localToken = localToken
                            self?.networkService.networkState = .local
                            self?.userService.setCurrentUser(user)
                            self?.userService.synchronizedCurrentUser()
                            self?.nextStepForLogin(callback: callBackClosure)
                        }else{
                          self?.nextStepForLogin(callback: callBackClosure)
                        }
                    })
                }else{
                    self?.nextStepForLogin(callback: callBackClosure)
                }
            }
        }else{
            nextStepForLogin(callback: callBackClosure)
        }
    }
    
    func nextStepForLogin(callback: @escaping (_ error:Error?,_ user:User?)->()) {
        let currentUser = self.userService.currentUser
        self.networkService.getUserHome { [weak self] (userHomeError, userHome) in
            if userHomeError != nil{
                self?.userService.logoutUser()
                return callback(userHomeError, currentUser);
            }
            
            currentUser?.userHome = userHome;
            self?.userService.synchronizedCurrentUser()
            AppNetworkService.getUserBackupDir(name: kBackUpAssetDirName, { (userBackupDirError, entryUUID) in
                if userBackupDirError != nil{
                    self?.userService.logoutUser()
                    return callback(userBackupDirError, currentUser);
                }else{
                    currentUser?.backUpDirectoryUUID = entryUUID;
                    AppUserService.synchronizedCurrentUser()
                }
                
               
                // MARK:Upload Opration
                //===================
//                if(!user.askForBackup)
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [weak_self requestForBackupPhotos:^(BOOL shouldUpload) {
//                user.askForBackup = YES;
//                user.autoBackUp = shouldUpload;
//                [WB_UserService synchronizedCurrentUser];
//                if(shouldUpload) {
//                [weak_self startUploadAssets:nil];
//                }
//                }];
//                });
//                else if(user.autoBackUp && WB_NetService.status == AFNetworkReachabilityStatusReachableViaWiFi)
//                [weak_self startUploadAssets:nil];
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                [weak_self updateCurrentUserInfoWithCompleteBlock:nil];
//                });
                self?.updateCurrentUserInfo()
                return callback(nil, currentUser);
            })
        }
    }
    
    func backupAseetsAction(){
        if let askForBackup = AppUserService.currentUser?.askForBackup{
            if !(askForBackup.boolValue) {
                
            }
        }else{
            self.requestForBackupPhotos(callback: { (isUpload) in
                AppUserService.currentUser?.autoBackUp = NSNumber.init(value: isUpload)
                AppUserService.currentUser?.askForBackup = NSNumber.init(value: false)
                AppUserService.synchronizedCurrentUser()
                
                //backUpStart
            })
        }
    }
    
    func rebuildAutoBackupManager(){
        if isRebuildingAutoBackupManager  {return}
        isRebuildingAutoBackupManager = false
        DispatchQueue.main.sync {
            autoBackupManager.destroy()
            self.updateUserBackupDirectory(callback: { [weak self](error, user) in
                if error == nil{
               self?.isRebuildingAutoBackupManager = false
                self?.autoBackupManager.start(localAssets: (self?.assetService.allAssets)!, netAssets: [EntriesModel]())
                self?.startAutoBackup(callBack: nil)
                }else{
                    print("--------->> Update User BackUp Dir Error <<------------- \n error: \(String(describing: error))")
                }
            })
        }
    }
    
    func updateUserBackupDirectory(callback:@escaping (_ error:Error?,_ user:User?)->()){
        AppNetworkService.getUserHome { [weak AppNetworkService](error, userHome) in
            if error != nil{
                return callback(error,nil)
            }else{
                AppUserService.currentUser?.userHome = userHome
                AppUserService.synchronizedCurrentUser()
                AppNetworkService?.getUserBackupDir(name: kBackupDirectory, { (backupDirerror, entryUUID) in
                    if error != nil{
                      return callback(backupDirerror,nil)
                    }else{
                        AppUserService.currentUser?.backUpDirectoryUUID = entryUUID
                        AppUserService.synchronizedCurrentUser()
                        return callback(nil, AppUserService.currentUser)
                    }
                })
            }
        }
    }
    
    func updateCurrentUserInfo(){
        UsersInfoAPI.init().startRequestDataCompletionHandler { (response) in
            if  response.error == nil{
                do {
                    let userModel = try JSONDecoder().decode(UserModel.self, from: response.data!)
                    if userModel.uuid == AppUserService.currentUser?.uuid{
                        AppUserService.currentUser?.isAdmin = userModel.isAdmin != nil ? NSNumber.init(value: userModel.isAdmin!) : nil
                        AppUserService.currentUser?.isFirstUser = userModel.isFirstUser != nil ? NSNumber.init(value: userModel.isFirstUser!) : nil 
                        if (userModel.global) != nil {
                            AppUserService.currentUser?.guid = userModel.global?.id;
//                            AppUserService.currentUser?.isBindWechat = YES;
                        }else{
//                            AppUserService.currentUser?.isBindWechat = NO;
                        }
                        AppUserService.synchronizedCurrentUser()
                    }
                } catch {
                    Message.message(text: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail)
                }
            }else{
                Message.message(text: (response.error?.localizedDescription)!)
            }
        }
    }
    
    func requestForBackupPhotos(callback: @escaping (_ shouldUpload:Bool)->()) {
        let alertTitle = LocalizedString(forKey: "backup_tips")
        let alertMessage = LocalizedString(forKey: "backup_alert_message")
        let cancelTitle = LocalizedString(forKey:"cancel")
        let confirmTitle = LocalizedString(forKey:"backup")
        Alert.alert(title: alertTitle, message: alertMessage, action1Title: confirmTitle, action2Title: cancelTitle, handler1: { (action) in
//            print("😁")
            callback(true)
            //    [[NSNotificationCenter defaultCenter] postNotificationName:UserBackUpConfigChangeNotify object:@(1)];
        }) { (action) in
//             print("👌")
            callback(false)
        }
        
        //    UIAlertAction *cancle = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //    NSLog(@"点击了取消按钮");
        //    WB_UserService.currentUser.autoBackUp = NO;
        //    [[NSNotificationCenter defaultCenter] postNotificationName:UserBackUpConfigChangeNotify object:@(0)];
        //    [WB_UserService synchronizedCurrentUser];
        //    callback(NO);
        //    }];
        //
        //    UIAlertAction *confirm = [UIAlertAction actionWithTitle:WBLocalizedString(@"backup", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //    NSLog(@"点击了确定按钮");
        //    WB_UserService.currentUser.autoBackUp = YES;
        //    [[NSNotificationCenter defaultCenter] postNotificationName:UserBackUpConfigChangeNotify object:@(1)];
        //    [WB_UserService synchronizedCurrentUser];
        //    callback(YES);
        //    }];
        //    [alertVc addAction:cancle];
        //    [alertVc addAction:confirm];
        //    [MyAppDelegate.window.rootViewController presentViewController:alertVc animated:YES completion:^{
        //    }];
    }
    
    var isStartingUpload = false
    var needRestart  = false
    func startAutoBackup(callBack:(()->())?){
        if  isStartingUpload {
            needRestart = true
            if((callBack) != nil){
                callBack!()
            }
            return
        }
        isStartingUpload = true
        let isWIFIBackup = self.userService.currentUser?.isWIFIAutoBackup?.boolValue ?? true
        if  (RealReachability.sharedInstance().currentReachabilityStatus() == ReachabilityStatus.RealStatusViaWiFi && isWIFIBackup) || (RealReachability.sharedInstance().currentReachabilityStatus() != ReachabilityStatus.RealStatusNotReachable && !isWIFIBackup){
            self.networkService.getEntriesInUserBackupDirectory { [weak self](error, entries) in
                if error != nil {
                    self?.isStartingUpload = false
                    if error is BaseError{
                        let baseErrot = error as! BaseError
                        if  baseErrot.code == ErrorCode.Backup.BackupDirNotFound{
                               self?.rebuildAutoBackupManager()
                        }
                    }else{
                        //retry
                    }
                }else{
                    print("Start Upload ...")
                    var netEntries = Array<EntriesModel>.init()
                    netEntries.append(contentsOf: netEntries)
//                    self?.autoBackupManager.setNetAssets(netAssets: netEntries)
                    self?.autoBackupManager.start(localAssets: (self?.assetService.allAssets)!, netAssets: netEntries)
//                    self?.autoBackupManager.startAutoBcakup()
                    self?.isStartingUpload = false
                    if(callBack != nil) {
                        callBack!()
                    }
                }
            }
        }else{
    //
        }
    }
    
    lazy var userService: UserService = {
        let service = UserService.init()
        return service
    }()
    
    lazy var networkService: NetworkService = {
        let service = NetworkService.init()
        return service
    }()
    
    lazy var assetService: AssetService = {
        let service = AssetService.init()
        return service
    }()
    
    lazy var dbService: DBService = {
        let service = DBService.init()
        return service
    }()
    
    lazy var tokenManager: TokenManager = {
        let manager = TokenManager.init()
        return manager
    }()
    
    lazy var autoBackupManager: AutoBackupManager = {
        let photoUploadManager = AutoBackupManager.init()
        return photoUploadManager
    }()
}


