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
    var isUserLogin:Bool?
    let moc = (UIApplication.shared.delegate
        as! AppDelegate)
    
    func abort() {
     }
    
    func setCurrentUser(_ currentUser:User?){
        if(currentUser == nil || currentUser?.uuid == nil || isNilString((currentUser?.uuid)!)) {
            return logoutUser()
        }
        defaultToken = currentUser?.localToken
        self.isUserLogin = true
        self.currentUser = currentUser;
        userDefaults.set(currentUser?.uuid, forKey: kCurrentUserUUID)
        userDefaultsSynchronize()
    }
    
    func logoutUser(){
        
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
    
    func createUser(uuid:String) ->User {
     return  User.mr_findFirstOrCreate(byAttribute: "uuid", withValue: uuid, in: NSManagedObjectContext.mr_default())
    }
}
