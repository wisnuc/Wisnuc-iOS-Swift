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
        if !(selectFilesArray?.contains(model))! {
            synced(self) {
                selectFilesArray?.append(model)
                if (selectFilesArray?.count == 1) {
                    defaultNotificationCenter().post(name: Notification.Name.Cell.SelectNotiKey, object: NSNumber.init(value: true))
                }
            }
        }
    }
    
    func removeSelectFiles(model:FilesModel){
        if (selectFilesArray?.contains(model))! {
            synced(self) {
                let index = selectFilesArray?.index(of: model)
                if index != nil{
                    selectFilesArray?.remove(at: index!)
                }
                if (selectFilesArray?.count == 0) {
                    defaultNotificationCenter().post(name: Notification.Name.Cell.SelectNotiKey, object: NSNumber.init(value: false))
                }
            }
        }
    }
    
    func removeAllSelectFiles(){
        synced(self) {
            selectFilesArray?.removeAll()
        }
    }
}
