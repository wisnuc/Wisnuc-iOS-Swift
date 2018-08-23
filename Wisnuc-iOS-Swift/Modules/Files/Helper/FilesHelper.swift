//
//  FilesHelper.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/10.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class FilesHelper: NSObject {
    var selectFilesArray:Array<EntriesModel>?
    private static var privateShared : FilesHelper?
    class func sharedInstance() -> FilesHelper { // change class to final to prevent override
        guard let uwShared = privateShared else {
            privateShared = FilesHelper()
            return privateShared!
        }
        return uwShared
    }
    
    class func destroy() {
        privateShared = nil
    }

    override init() {
        selectFilesArray = Array<EntriesModel>.init()
    }

    deinit {
        
    }
    
    
    func addSelectFiles(model:EntriesModel){
        if !(selectFilesArray?.contains(where: { $0.uuid == model.uuid }))! {
            synced(self) {
                selectFilesArray?.append(model)
                if (selectFilesArray?.count == 1) {
                    defaultNotificationCenter().post(name: Notification.Name.Cell.SelectNotiKey, object: NSNumber.init(value: true))
                }
            }
        }
    }
    
    func addAllSelectFiles(array:Array<EntriesModel>){
        synced(self) {
            selectFilesArray = array
            if (selectFilesArray?.count == 1) {
                defaultNotificationCenter().post(name: Notification.Name.Cell.SelectNotiKey, object: NSNumber.init(value: true))
            }
        }
    }
    
    func removeSelectFiles(model:EntriesModel){
        if (selectFilesArray?.contains(where:{$0.uuid == model.uuid}))! {
            synced(self) {
                let index = selectFilesArray?.index(where: {$0.uuid == model.uuid})
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
