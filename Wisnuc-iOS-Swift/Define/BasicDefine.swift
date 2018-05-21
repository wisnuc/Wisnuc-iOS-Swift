//
//  BasicDefine.swift
//  FruitMix-Swift
//
//  Created by wisnuc-imac on 2018/3/16.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import UIKit

public func LocalizedString(forKey key:String) -> String {
  return Bundle.main.localizedString(forKey: key, value:"", table: nil)
}

public func defaultNotificationCenter() -> NotificationCenter{
    return NotificationCenter.default
}


