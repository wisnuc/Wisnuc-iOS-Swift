//
//  AppService.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/23.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit


let MainServices = AppService.sharedInstance
let AppUserService =  MainServices().userService
let AppNetworkService =  MainServices().networkService
let AppTokenManager =  MainServices().tokenManager

class AppService: NSObject,ServiceProtocol{
    
    private static var privateShared : AppService?
    class func sharedInstance() -> AppService { // change class to final to prevent override
        guard let uwShared = privateShared else {
            privateShared = AppService()
            return privateShared!
        }
        return uwShared
    }
    
    override init() {
        
    }
    
    func abort() {
        NetEngine.sharedInstance.cancleAllRequest()
        userService.abort()
        print("Disposed Singleton instance")
    }
    
    deinit {
       
    }
    
    func loginAction(model:CloadLoginUserRemotModel,orginTokenUser:User,complete:@escaping ((_ error:Error?,_ user:User?)->())){
        if model.uuid == nil || isNilString(model.uuid){
            complete(LoginError(code: ErrorCode.Login.NoUUID, kind: LoginError.ErrorKind.LoginNoUUID, localizedDescription: LocalizedString(forKey: "UUID is not exist")), nil)
        }
        
        let callBackClosure = { (callBackError:Error? , callBackUser:User?)->() in
            complete(callBackError,callBackUser)
        }
//        void(^_callback)(NSError *error, WBUser *user) = ^(NSError *error, WBUser *user) {
//            _isLogining = NO;
//            callback(error, user);
//        };
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
            let urlString  = "http://\(String(describing: model.LANIP)):3000"
            user.localAddr = urlString
        }
        self.userService.setCurrentUser(user)
        self.userService.synchronizedCurrentUser()
        if user.localAddr != nil{
            networkService.checkIP(address: user.localAddr!) { [weak self] (success) in
                if success{
                    self?.networkService.getLocalInCloudLogin({ (localTokenError, localToken) in
                        if localTokenError == nil{
                            user.isLocalLogin = NSNumber.init(value: true)
                            user.localToken = localToken
                            self?.userService.setCurrentUser(user)
                            self?.userService.synchronizedCurrentUser()
                            self?.nextStepForLogin(callback: callBackClosure)
                        }
                          self?.nextStepForLogin(callback: callBackClosure)
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
        }
//        WBUser * user = WB_UserService.currentUser;
//        @weaky(self);
//        [WB_NetService getUserHome:^(NSError *error, NSString *userHome) {
//        if(error) {
//        [WB_UserService logoutUser];
//        return callback(({error.wbCode = 10002; error;}), user);
//        }
//        user.userHome = userHome;
//        [WB_UserService synchronizedCurrentUser];
//        NSLog(@"GET USER HOME SUCCESS");
//        [WB_NetService getUserBackupDirName:BackUpAssetDirName BackupDir:^(NSError *error, NSString *entryUUID) {
//        if(error) {
//        [WB_UserService logoutUser];
//        return callback(({error.wbCode = 10003; error;}), user);
//        }
//        user.backUpDir = entryUUID;
//        [WB_UserService synchronizedCurrentUser];
//        NSLog(@"GET BACKUP DIR SUCCESS");
//        NSLog(@"%d",user.askForBackup);
//        if(!user.askForBackup)
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [weak_self requestForBackupPhotos:^(BOOL shouldUpload) {
//        user.askForBackup = YES;
//        user.autoBackUp = shouldUpload;
//        [WB_UserService synchronizedCurrentUser];
//        if(shouldUpload) {
//        [weak_self startUploadAssets:nil];
//        }
//        }];
//        });
//        else if(user.autoBackUp && WB_NetService.status == AFNetworkReachabilityStatusReachableViaWiFi)
//        [weak_self startUploadAssets:nil];
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [weak_self updateCurrentUserInfoWithCompleteBlock:nil];
//        });
//        return callback(nil, user);
//        }];
//        }];
    }
    
    lazy var userService: UserService = {
        let service = UserService.init()
        return service
    }()
    
    lazy var networkService: NetworkService = {
        let service = NetworkService.init()
        return service
    }()
    
    lazy var tokenManager: TokenManager = {
        let manager = TokenManager.init()
        return manager
    }()
}


