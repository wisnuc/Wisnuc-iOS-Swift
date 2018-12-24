 //
//  AppService.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/23.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MDCAlertController
import MagicalRecord
 
 enum DriveType:String{
    case home
    case share = "bulit-in"
    case backup
 }

let MainServices = AppService.sharedInstance
let AppUserService =  MainServices().userService
let AppNetworkService =  MainServices().networkService
let AppAssetService =  MainServices().assetService
let AppDBService =  MainServices().dbService
let AppTokenManager =  MainServices().tokenManager

class AppService: NSObject,ServiceProtocol{
    private var isRebuildingAutoBackupManager = false
    private static var privateShared : AppService?
    var backupuuid:String?
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
        LocalizeHelper.instance.dispose()
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
                self?.nextStepForLogin(user: user, callback: callBackClosure)
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
                            self?.nextStepForLogin(user: user, callback: callBackClosure)
                        }else{
                            self?.nextStepForLogin(user: user, callback: callBackClosure)
                        }
                    })
                }else{
                    self?.nextStepForLogin(user: user, callback: callBackClosure)
                }
            }
        }else{
            nextStepForLogin(user: user, callback: callBackClosure)
        }
    }
    
    func loginAction(stationModel:StationsInfoModel,orginTokenUser:User,complete:@escaping ((_ error:Error?,_ user:User?)->())){
//        if model.uuid == nil || isNilString(model.uuid){
//            complete(LoginError(code: ErrorCode.Login.NoUUID, kind: LoginError.ErrorKind.LoginNoUUID, localizedDescription: LocalizedString(forKey: "UUID is not exist")), nil)
//        }
        
        let resultUser = orginTokenUser
        let callBackClosure = { (callBackError:Error? , callBackUser:User?)->() in
            if callBackError != nil{
                complete(callBackError,orginTokenUser.shallowCopy() as? User)
            }else{
                complete(callBackError,callBackUser)
            }
        }

        resultUser.stationId = stationModel.sn
        if let isShare  = stationModel.isShareStation{
            resultUser.isAdmin = NSNumber.init(value: !isShare)
        }
        resultUser.isLocalLogin = NSNumber.init(value: false)
        
        if let lanIP = stationModel.LANIP {
            let urlString  = "http://\(String(describing: lanIP)):3000"
            resultUser.localAddr = urlString
            resultUser.lanIP = lanIP
        }
      
        if resultUser.localAddr != nil{
            networkService.checkIP(address: resultUser.lanIP!) { [weak self] (success) in
                if success{
                    self?.networkService.getLocalInCloudLogin(cloudToken: resultUser.cloudToken, { [weak self](localTokenError, localToken) in
                        if localTokenError == nil{
                            resultUser.isLocalLogin = NSNumber.init(value: true)
                            resultUser.localToken = localToken
                            self?.networkService.networkState = .local
                            self?.nextStepForLogin(user: resultUser, callback: callBackClosure)
                        }else{
                            self?.nextStepForLogin(user: resultUser, callback: callBackClosure)
                        }
                    })
                }else{
                    self?.nextStepForLogin(user: resultUser, callback: callBackClosure)
                }
            }
        }else{
            nextStepForLogin(user: resultUser, callback: callBackClosure)
        }
    }
    
    func nextStepForLogin(user:User,callback: @escaping (_ error:Error?,_ user:User?)->()) {
        self.networkService.getUserAllDrive(user: user) { [weak self] (userHomeError, driveModels) in
            if userHomeError != nil{
                return callback(userHomeError, user)
            }
        
            if let driveModels = driveModels{
                for model in driveModels{
                    if model.tag == DriveType.home.rawValue &&  model.type ==  "classic"{
                        user.userHome = model.uuid
                    }else if model.tag == DriveType.share.rawValue{
                        user.shareSpace = model.uuid
                    }else if model.type == DriveType.backup.rawValue{
                        if let uuid = model.uuid{
                            if !(self?.userService.backupArray.contains(where: {$0.uuid == uuid}))!{
                                self?.userService.backupArray.append(model)
                            }
                        }
                    }
                }
            }
    
            self?.loginCreatBackupDriveStep(user:user)
            return callback(nil, user)
        }
    }
    
    func loginCreatBackupDriveStep(user:User){
        if self.userService.backupArray.count == 0 || !(self.userService.backupArray.contains(where: {$0.client?.id == getUniqueDevice()})){
            self.networkService.creactBackupDrive(user:user,callBack: { [weak self](error, driveModel) in
                if driveModel != nil && error == nil{
                    if let driveModel = driveModel{
                        if let uuid = driveModel.uuid{
                            if !(self?.userService.backupArray.contains(where: {$0.uuid == uuid}))!{
                                self?.userService.backupArray.append(driveModel)
                            }
                        }
                    }
                }
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
                    guard let uuid = self?.backupuuid else{
                        return
                    }
                    self?.startAutoBackup(uuid: uuid, callBack: nil)
                }else{
                    print("--------->> Update User BackUp Dir Error <<------------- \n error: \(String(describing: error))")
                }
            })
        }
    }
    
    func updateUserBackupDirectory(callback:@escaping (_ error:Error?,_ user:User?)->()){
//        AppNetworkService.getUserHome { [weak AppNetworkService](error, userHome) in
//            if error != nil{
//                return callback(error,nil)
//            }else{
//                AppUserService.currentUser?.userHome = userHome
//                AppUserService.synchronizedCurrentUser()
//                AppNetworkService?.getUserBackupDir(name: kBackupDirectory, { (backupDirerror, entryUUID) in
//                    if error != nil{
//                      return callback(backupDirerror,nil)
//                    }else{
//                        AppUserService.currentUser?.backUpDirectoryUUID = entryUUID
//                        AppUserService.synchronizedCurrentUser()
//                        return callback(nil, AppUserService.currentUser)
//                    }
//                })
//            }
//        }
    }
    
    
    
    func logoutAction(){
        AppUserService.logoutUser()
        AppService.sharedInstance().abort()
        appDelegate.initRootVC()
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
    func startAutoBackup(uuid:String,callBack:(()->())?){
        self.backupuuid = uuid
        self.autoBackupManager.uuid = uuid
        if  isStartingUpload {
            needRestart = true
            if((callBack) != nil){
                callBack!()
            }
            return
        }
        isStartingUpload = true
        let isWIFIBackup = self.userService.currentUser?.isWIFIAutoBackup?.boolValue ?? false
        if  (RealReachability.sharedInstance().currentReachabilityStatus() == ReachabilityStatus.RealStatusViaWiFi && isWIFIBackup) || (RealReachability.sharedInstance().currentReachabilityStatus() != ReachabilityStatus.RealStatusNotReachable && !isWIFIBackup){
            self.networkService.getEntriesInUserBackupDirectory(uuid: uuid) { [weak self](error, entries) in
                if error != nil {
                    self?.isStartingUpload = false
                    if error is BaseError{
                        let baseErrot = error as! BaseError
                        if  baseErrot.code == ErrorCode.Backup.BackupDirNotFound{
                            self?.rebuildAutoBackupManager()
                        }
                    }else{
                         self?.rebuildAutoBackupManager()
                    }
                }else{
                    print("Start Upload ...")
                    var netEntries = Array<EntriesModel>.init()
                    netEntries.append(contentsOf: netEntries)
//                    self?.autoBackupManager.setNetAssets(netAssets: netEntries)
                    
                    self?.autoBackupManager.start(localAssets: (self?.assetService.allAssets)!, netAssets: netEntries)
                    self?.autoBackupManager.startAutoBcakup()
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
    
    func saveUserUsedDeviceInfo(sn:String,token:String,closure:@escaping ()->()){
        let request =  UserDeviceInfoAPI.init(sn: sn, token: token)
        request.startRequestJSONCompletionHandler { (response) in
            if let error = response.error {
                Message.message(text: error.localizedDescription)
            }else{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                    return
                }
                return closure()
            }
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
        service.assetChangeBlock = { [weak self](removeObjs, insertObjs) in
            self?.autoBackupManager.addTasks(insertObjs)
            self?.autoBackupManager.removeTasks(removeObjs)
        }
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


