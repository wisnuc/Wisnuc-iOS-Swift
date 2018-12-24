//
//  User+CoreDataClass.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/22.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {
    public override func copy() -> Any {
        let copy = User.init(entity: self.entity, insertInto: self.managedObjectContext)
        copy.localToken = self.localToken
        copy.uuid = self.uuid
        copy.cloudToken =  self.cloudToken
        copy.avaterURL =  self.avaterURL
        copy.userName =  self.userName
        copy.nickName =  self.nickName
        copy.stationId =  self.stationId
        copy.localAddr =  self.localAddr
        copy.lanIP =  self.lanIP
        copy.isFirstUser =  self.isFirstUser
        copy.isAdmin =  self.isAdmin
        copy.bonjour_name =  self.bonjour_name
        copy.isLocalLogin =  self.isLocalLogin
        copy.backUpDirectoryUUID =  self.backUpDirectoryUUID
        copy.guid =  self.guid
        copy.sortType =  self.sortType
        copy.sortIsDown =  self.sortIsDown
        copy.isListStyle =  self.isListStyle
        copy.autoBackUp =  self.autoBackUp
        copy.isWIFIAutoBackup =  self.isWIFIAutoBackup
        copy.language =  self.language
        copy.isSelectStation =  self.isSelectStation
        copy.cookie =  self.cookie
        copy.mail =  self.mail
        copy.safety =  self.safety
        copy.shareSpace =  self.shareSpace
        return copy
    }
}
