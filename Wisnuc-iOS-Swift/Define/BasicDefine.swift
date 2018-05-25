//
//  BasicDefine.swift
//  FruitMix-Swift
//
//  Created by wisnuc-imac on 2018/3/16.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import UIKit


let appDlegate = UIApplication.shared.delegate as! AppDelegate
public let userDefaults = UserDefaults.standard
let infoDictionary = Bundle.main.infoDictionary
let kCurrentAppVersion = infoDictionary!["CFBundleShortVersionString"] as! String
let kCurrentSystemVersion = (UIDevice.current.systemVersion as NSString).doubleValue

public func LocalizedString(forKey key:String) -> String {
  return Bundle.main.localizedString(forKey: key, value:"", table: nil)
}

public func defaultNotificationCenter() -> NotificationCenter{
    return NotificationCenter.default
}

public func userDefaultsSynchronize() {
    UserDefaults.standard.synchronize()
}




