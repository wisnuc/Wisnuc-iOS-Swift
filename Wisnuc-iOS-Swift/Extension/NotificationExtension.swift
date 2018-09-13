
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
    
    public struct Backup {
        public static let HashCalculateFinishedNotiKey = Notification.Name(rawValue: "app.notification.name.HashCalculateFinishedNotiKey")
         public static let AutoBackupDestroyedNotiKey = Notification.Name(rawValue: "app.notification.name.AutoBackupDestroyedNotiKey")
         public static let AutoBackupCountChangeNotiKey = Notification.Name(rawValue: "app.notification.name.AutoBackupCountChangeNotiKey")
    }
    
    public struct Login {
        public static let CreatAccountFinishDismissKey = Notification.Name(rawValue: "app.notification.name.CreatAccountFinishDismissKey")
    }
}
