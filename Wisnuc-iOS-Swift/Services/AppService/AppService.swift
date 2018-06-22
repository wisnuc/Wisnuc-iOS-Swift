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
                self?.updateCurrentUserInfo()
                return callback(nil, currentUser);
            })
        }
    }
    
    
    func updateCurrentUserInfo(){
        UsersInfoAPI.init().startRequestDataCompletionHandler { (response) in
            if  response.error == nil{
                do {
                    let userModel = try JSONDecoder().decode(UserModel.self, from: response.data!)
                    if userModel.uuid == AppUserService.currentUser?.uuid{
                        AppUserService.currentUser?.isAdmin = NSNumber.init(value: userModel.isAdmin!)
                        AppUserService.currentUser?.isFirstUser = NSNumber.init(value: userModel.isFirstUser!)
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


