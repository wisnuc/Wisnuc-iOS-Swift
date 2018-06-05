
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
}

public let KWxAppID = "wx99b54eb728323fe8"
public let kCloudAddr = "http://www.siyouqun.com"
public let kCloudBaseURL = "http://www.siyouqun.com/c/v1"
//#define kCloudAddr    @"http://10.10.9.87:4000/"
//#define WX_BASE_URL   @"http://10.10.9.87:4000/c/v1/"

public let kCloudCommonJsonUrl = "/stations/\(String(describing: (AppUserService.currentUser?.stationId!)!))/json"
public let kRquestDrivesURL = "drives"
public let kRequestMkdirValue = "mkdir"
public let kBackUpAssetDirName  = "上传的照片"

public let kFirstLaunchKey =  "kFirstLaunchKey"
public let kappVersionKey =  "kappVersionKey"
public let kCurrentUserUUID = "kCurrentUserUUID"
public let kBackupBaseEntryKey = "kBackupBaseEntryKey"
public let kBackupDirectory = "kBackupDirectory"

public let kRequestAuthorizationKey = "Authorization"
public let kRequestMethodKey = "method"
public let kRequestResourceKey = "resource"
public let kRequestOpKey       = "op"
public let kRequestToNameKey  =  "toName"
public let kRequestFromNameKey  = "fromName"

public let kHTTPTCPSearchBrowerType = "_http._tcp"


