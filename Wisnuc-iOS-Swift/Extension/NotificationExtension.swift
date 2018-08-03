
//
//  NotificationExtension.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/21.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation

extension Notification.Name{
    public struct Cell {
        public static let SelectNotiKey = Notification.Name(rawValue: "cell.notification.name.select")

    }
    
    public struct Refresh {
        public static let MoveRefreshNotiKey = Notification.Name(rawValue: "cell.notification.name.moveRefresh")
        
    }
    
    public struct Change {
        public static let PhotoCollectionUserAuthChangeNotiKey = Notification.Name(rawValue: "app.notification.name.photoCollectionUserAuthChange")
        public static let LocalLoginDismissNotiKey = Notification.Name(rawValue: "app.notification.name.LocalLoginDismissNotiKey")
        public static let AssetChangeNotiKey = Notification.Name(rawValue: "app.notification.name.AssetChangeNotiKey")
        
    }
    
    
}
