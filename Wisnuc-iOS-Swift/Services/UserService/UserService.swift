//
//  UserService.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/23.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MagicalRecord

class UserService: NSObject,ServiceProtocol{
    var defaultToken:String?
    var currentUser:User?
    var isUserLogin:Bool = false
    var isStationSelected:Bool = false
    lazy var backupArray:[DriveModel] = [DriveModel]()
    var isLocalLogin:Bool?{
        didSet{
            if isLocalLogin == true {
                AppNetworkService.networkState = .local
            }else{
                AppNetworkService.networkState = .normal
            }
        }
    }
    
    override init() {
        super.init()
        load()
    }
     
    func load(){
        if userDefaults.object(forKey: kCurrentUserUUID) != nil || !isNilString(userDefaults.object(forKey: kCurrentUserUUID) as? String)  {
            let uuid = userDefaults.object(forKey: kCurrentUserUUID) as! String
            self.currentUser = user(uuid: uuid)
            if self.currentUser == nil || self.currentUser?.isLocalLogin == nil || currentUser?.isSelectStation == nil{
                self.isUserLogin = false
             
//                userDefaults.removeObject(forKey: kCurrentUserUUID)
//                userDefaults.synchronize()
                return
            }
            
            if !(currentUser?.isSelectStation?.boolValue)! {
                self.isStationSelected = false
                return
            }
            
            self.isUserLogin = true
            self.isStationSelected = true
//            if let uuid = self.currentUser?.uuid{
//                if let backupArray = userDefaults.array(forKey: "\(kBackupDrives)_\(uuid)") as? [DriveModel]{
//                    self.backupArray = backupArray
//                }
//            }
        }else{
            self.currentUser = nil
            self.isStationSelected = false
            self.isUserLogin = false
            self.defaultToken = nil
        }
    }
    
    func abort() {
     
    }
    
    deinit {
        
    }
    
    func synchronizedUserInLogin(_ model:SighInTokenModel,_ cookie:String)->User{
        let user = self.createUser(uuid: (model.data?.id)!)
        user.cloudToken = model.data?.token!
        if let avatarUrl = model.data?.avatarUrl{
            user.avaterURL = avatarUrl
        }
        user.cookie = cookie
        
        if let nickName = model.data?.nickName{
            user.nickName = nickName
        }
        
        if let username = model.data?.username{
            user.userName = username
        }
        
        if let mail = model.data?.mail{
            user.mail = mail
        }
        
        if let safety = model.data?.safety{
            user.safety = NSNumber.init(value: safety)
        }
        
        return user
    }

    func setCurrentUser(_ currentUser:User?){
        if(currentUser == nil || currentUser?.uuid == nil || isNilString((currentUser?.uuid)!)) {
            return logoutUser()
        }
       
        defaultToken = currentUser?.localToken
        self.currentUser = currentUser;
        userDefaults.set(currentUser?.uuid, forKey: kCurrentUserUUID)
        userDefaultsSynchronize()
        isLocalLogin = self.currentUser?.isLocalLogin?.boolValue
        self.isUserLogin = true
    }
    
    func logoutUser(){
        isUserLogin = false
        isStationSelected = false
        currentUser?.isSelectStation = NSNumber.init(value: isStationSelected)
        synchronizedCurrentUser()
        currentUser = nil
        isLocalLogin = nil
        userDefaults.removeObject(forKey: kCurrentUserUUID)
        userDefaults.synchronize()
        NetEngine.sharedInstance.cancleAllRequest()
        defaultNotificationCenter().removeObserver(self)
    }
    
    func updateCurrentUserInfo(complete:@escaping ()->()){
        UsersInfoAPI.init().startRequestDataCompletionHandler { (response) in
            if  response.error == nil{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                    return
                }
                
                guard let rootDic = dataToNSDictionary(data: response.data)else {
                    return
                }
                
                guard let dataDic = rootDic["data"] as? NSDictionary else {
                    return
                }
                
                guard let data = jsonToData(jsonDic: dataDic) else {
                    return
                }
                
                do {
                    let userModel = try JSONDecoder().decode(UserModel.self, from: data)
                    if userModel.id == AppUserService.currentUser?.uuid{
                        AppUserService.currentUser?.userName = userModel.username
                        AppUserService.currentUser?.avaterURL = userModel.avatarUrl
                        AppUserService.currentUser?.nickName = userModel.nickName
                        AppUserService.currentUser?.userName = userModel.username
                        AppUserService.synchronizedCurrentUser()
                        complete()
                    }
                } catch {
                    Message.message(text: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail)
                }
            }else{
                switch response.error {
                case is BaseError:
                    let baseError = response.error as! BaseError
                    Message.message(text: baseError.localizedDescription)
                default:
                    Message.message(text: (response.error?.localizedDescription)!)
                }
            }
        }
    }
    
    func user(uuid:String) ->User?{
        let predicate = NSPredicate(format: "uuid = %@", uuid)
        let user = User.mr_findFirst(with: predicate)
        return user
    }
    
    func synchronizedCurrentUser(){
      let _ = saveUser(self.currentUser)
    }
    
    func saveUser(_ user:User?) -> User?{
        if(user == nil) {
            return nil
        }
        
        if user?.uuid == nil || isNilString(user?.uuid) {
            user?.mr_deleteEntity()
            return nil
        }
        
        if(user?.uuid == self.currentUser?.uuid){
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
        self.currentUser = user
        }
        return user
    }
    
    func deleteUser(uuid :String){
        let predicate = NSPredicate.init(format: "uuid = %@",uuid)
        let users:Array<User> = User.mr_findAll(with: predicate) as! Array<User>
        for user in users {
            user.mr_deleteEntity()
        }
        NSManagedObjectContext.mr_default().mr_saveToPersistentStoreAndWait()
    }
    
    func updateUserDefaultCurrentUUID(uuid:String) {
        userDefaults.set(uuid, forKey: kCurrentUserUUID)
        userDefaults.synchronize()
    }
    
    func createUser(uuid:String) ->User {
     return  User.mr_findFirstOrCreate(byAttribute: "uuid", withValue: uuid, in: NSManagedObjectContext.mr_default())
    }
}
