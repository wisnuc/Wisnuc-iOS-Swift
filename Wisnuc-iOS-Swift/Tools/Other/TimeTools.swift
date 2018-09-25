//
//  TimeTools.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/25.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class TimeTools: NSObject {
    class func getCurrentDay()->String{
        let date = Date.init(timeIntervalSinceNow: 0)
        var interval: Int = NSTimeZone.system.secondsFromGMT(for: date)
        var localeDate = date.addingTimeInterval(TimeInterval(interval))
        let formater = DateFormatter.init()
        formater.dateFormat = "MM月dd日"
        let dateString = formater.string(from: localeDate)
        return dateString
    }
}
