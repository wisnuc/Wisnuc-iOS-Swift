
//
//  KeyStringDefine.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/16.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation

struct RequestMethodValue {
    public static let GET:String = "GET"
    public static let POST:String = "POST"
    public static let DELETE:String = "DELETE"
    public static let PUT:String = "PUT"
    public static let PATCH:String = "PATCH"
}

struct RequestMediaClassValue {
    public static let Image:String = "image"
    public static let Video:String = "video"
}

public let kFirstLaunchKey =  "kFirstLaunchKey"
public let kappVersionKey =  "kappVersionKey"
public let kCurrentUserUUID = "kCurrentUserUUID"
public let kBackupBaseEntryKey = "kBackupBaseEntryKey"
public let kBackupDirectory = "kBackupDirectory"

public let kAssetsRemovedKey = "kAssetsRemovedKey"
public let kAssetsInsertedKey = "kAssetsInsertedKey"


public let kBLEUsedKey = "kBLEUsedKey"
