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
    let moc = (UIApplication.shared.delegate
        as! AppDelegate)
    
    override init() {
        super.init()
        load()
    }
     
    func load(){
        if userDefaults.object(forKey: kCurrentUserUUID) != nil || !isNilString(userDefaults.object(forKey: kCurrentUserUUID) as? String)  {
            let uuid = userDefaults.object(forKey: kCurrentUserUUID) as! String
            self.currentUser = user(uuid: uuid)
            if self.currentUser == nil || ((self.currentUser?.isLocalLogin) == nil){
                self.isUserLogin = false
//                userDefaults.removeObject(forKey: kCurrentUserUUID)
//                userDefaults.synchronize()
                return
            }
            self.isUserLogin = true
        }else{
            self.currentUser = nil
            self.isUserLogin = false
            self.defaultToken = nil
        }
    }
    
    func abort() {
     
    }
    
    deinit {
        
    }

    func setCurrentUser(_ currentUser:User?){
        if(currentUser == nil || currentUser?.uuid == nil || isNilString((currentUser?.uuid)!)) {
            return logoutUser()
        }
        defaultToken = currentUser?.localToken
        self.currentUser = currentUser;
        userDefaults.set(currentUser?.uuid, forKey: kCurrentUserUUID)
        userDefaultsSynchronize()
        self.isUserLogin = true
    }
    
    func logoutUser(){
        isUserLogin = false
        currentUser = nil
        userDefaults.removeObject(forKey: kCurrentUserUUID)
        userDefaults.synchronize();
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
