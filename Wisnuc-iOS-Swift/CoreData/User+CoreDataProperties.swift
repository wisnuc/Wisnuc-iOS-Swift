//
//  User+CoreDataProperties.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/22.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var localToken: String?
    @NSManaged public var uuid: String?
    @NSManaged public var cloudToken: String?
    @NSManaged public var avaterURL: String?
    @NSManaged public var userName: String?
    @NSManaged public var stationId: String?
    @NSManaged public var localAddr: String?
    @NSManaged public var isFirstUser: NSNumber?
    @NSManaged public var isAdmin: NSNumber?
    @NSManaged public var bonjour_name: String?
    @NSManaged public var isLocalLogin:NSNumber?
    @NSManaged public var userHome:String?
    @NSManaged public var backUpDirectoryUUID:String?
    @NSManaged public var guid:String?
    @NSManaged public var sortType:NSNumber?
    @NSManaged public var sortIsDown:NSNumber?
    @NSManaged public var isListStyle:NSNumber?
    @NSManaged public var autoBackUp:NSNumber?
    @NSManaged public var askForBackup:NSNumber?
    @NSManaged public var isWIFIAutoBackup:NSNumber?
    @NSManaged public var language:NSNumber?
    @NSManaged public var retrievePasswordState:NSNumber?
}
