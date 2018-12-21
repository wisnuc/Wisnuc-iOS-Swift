//
//  BasicDefine.swift
//  FruitMix-Swift
//
//  Created by wisnuc-imac on 2018/3/16.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import UIKit

public let kKeyChainService = "com.wisnuc"
public let kKeyChainAccount = "wisnuc"
public let kBackupDrives = "backupDrives"
let appDelegate = UIApplication.shared.delegate as! AppDelegate
public let userDefaults = UserDefaults.standard
let infoDictionary = Bundle.main.infoDictionary
let kCurrentAppVersion = infoDictionary!["CFBundleShortVersionString"] as! String
let kAppId = "1132191394"
let kBackupClientType = "iOS-Mobile"
let kCurrentSystemVersion = (UIDevice.current.systemVersion as NSString).doubleValue
let kWindow = UIApplication.shared.keyWindow
var kStatusBarHeight = UIApplication.shared.statusBarFrame.size.height


public func LocalizedString(forKey key:String) -> String{
   if let string = LocalizeHelper.instance.localizedString(forKey: key){
      return string
   }
  return Bundle.main.localizedString(forKey: key, value:"", table: nil)
}

public func defaultNotificationCenter() -> NotificationCenter{
    return NotificationCenter.default
}

public func userDefaultsSynchronize() {
    UserDefaults.standard.synchronize()
}




