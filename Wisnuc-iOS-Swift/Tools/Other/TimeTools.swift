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
        let interval: Int = NSTimeZone.system.secondsFromGMT(for: date)
        let localeDate = date.addingTimeInterval(TimeInterval(interval))
        let formater = DateFormatter.init()
        formater.dateFormat = "MM月dd日"
        let dateString = formater.string(from: localeDate)
        return dateString
    }
    
    class func getYear(date:Date)->String{
        let interval: Int = NSTimeZone.system.secondsFromGMT(for: date)
        let localeDate = date.addingTimeInterval(TimeInterval(interval))
        let formater = DateFormatter.init()
        formater.dateFormat = "yyyy"
        let dateString = formater.string(from: localeDate)
        return dateString
    }
    
    class func timeHourMinuteString(_ timeSecond:TimeInterval)->String{
        let date = Date.init(timeIntervalSince1970: timeSecond)
        let formater = DateFormatter.init()
        formater.dateFormat = "hh:mm"
        let dateString = formater.string(from: date)
        return dateString
    }
    
    class func timeHourMinuteString(_ date:Date)->String{
        let formater = DateFormatter.init()
        formater.dateFormat = "hh:mm"
        let dateString = formater.string(from: date)
        return dateString
    }
    
    class func timeString(_ timeSecond:TimeInterval) ->String{
        let date = Date.init(timeIntervalSince1970: timeSecond)
        let formater = DateFormatter.init()
        formater.dateFormat = "yyyy年MM月dd日"
        //    "yyyy年MM月dd日 hh:mm:ss"
        let timeZone = NSTimeZone.init(name:"Asia/Shanghai")
        formater.timeZone = timeZone! as TimeZone
        let dateString = formater.string(from: date)
        return dateString
    }
    
    class func timeString(_ date:Date) ->String{
        let formater = DateFormatter.init()
        formater.dateFormat = "yyyy年MM月dd日"
        //    "yyyy年MM月dd日 hh:mm:ss"
        let timeZone = NSTimeZone.init(name:"Asia/Shanghai")
        formater.timeZone = timeZone! as TimeZone
        let dateString = formater.string(from: date)
        return dateString
    }
    
    class func dateTimeInterval(_ string:String) ->TimeInterval?{
        let formater = DateFormatter.init()
        formater.dateFormat = "yyyy:MM:dd HH:mm:ss"
        //    "yyyy年MM月dd日 hh:mm:ss"
        let date = formater.date(from: string)
       
        let time = date?.timeIntervalSince1970
        return time
    }
    
    class func weekDay(_ timeSecond:TimeInterval) ->String {
        let weekDays = [NSNull.init(),"星期日","星期一","星期二","星期三","星期四","星期五","星期六"] as [Any]
        let newDate = Date(timeIntervalSince1970: timeSecond)
        let calendar = NSCalendar.init(calendarIdentifier: .gregorian)
        let timeZone = NSTimeZone.init(name:"Asia/Shanghai")
        calendar?.timeZone = timeZone! as TimeZone
        let calendarUnit = NSCalendar.Unit.weekday
        let theComponents = calendar?.components(calendarUnit, from: newDate)
        return weekDays[(theComponents?.weekday)!] as! String
    }
    
    class func weekDay(_ date:Date) ->String {
        let weekDays = [NSNull.init(),"星期日","星期一","星期二","星期三","星期四","星期五","星期六"] as [Any]
        let newDate = date
        let calendar = NSCalendar.init(calendarIdentifier: .gregorian)
        let timeZone = NSTimeZone.init(name:"Asia/Shanghai")
        calendar?.timeZone = timeZone! as TimeZone
        let calendarUnit = NSCalendar.Unit.weekday
        let theComponents = calendar?.components(calendarUnit, from: newDate)
        return weekDays[(theComponents?.weekday)!] as! String
    }
}
