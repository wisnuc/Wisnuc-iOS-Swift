//
//  FilesHelper.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/10.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class FilesHelper: NSObject {
    var selectFilesArray:Array<FilesModel>?
    static let sharedInstance = FilesHelper()
    private override init(){
        super.init()
        selectFilesArray = []
    }
    
    func addSelectFiles(model:FilesModel){
        //互斥锁
        if !(selectFilesArray?.contains(model))! {
            objc_sync_enter(self)
            selectFilesArray?.append(model)
            if (selectFilesArray?.count == 1) {
                defaultNotificationCenter().post(name: Notification.Name.Cell.SelectNotiKey, object: NSNumber.init(value: true))
            }
            objc_sync_exit(self)
        }
    }
    
    func removeSelectFiles(model:FilesModel){
        //互斥锁
        if (selectFilesArray?.contains(model))! {
            objc_sync_enter(self)
            let index = selectFilesArray?.index(of: model)
            if index != nil{
                selectFilesArray?.remove(at: index!)
            }
            if (selectFilesArray?.count == 0) {
                defaultNotificationCenter().post(name: Notification.Name.Cell.SelectNotiKey, object: NSNumber.init(value: false))
            }
            objc_sync_exit(self)
        }
    }
    
    func removeAllSelectFiles(){
        //互斥锁
            objc_sync_enter(self)
            selectFilesArray?.removeAll()
        
            objc_sync_exit(self)
    }
}
