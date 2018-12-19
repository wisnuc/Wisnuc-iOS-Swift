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
             self.addTrueFiles(model: model)
        }else{
            let name = model.backupRoot ? model.bname ?? model.name ?? "" : model.name ?? ""
            if !(FilesHelper.sharedInstance().selectFilesArray?.contains(where:{$0.name == name}))!{
               self.addTrueFiles(model: model)
            }
        }
    }
    
    private func addTrueFiles(model:EntriesModel){
        synced(self) {
            selectFilesArray?.append(model)
            if (selectFilesArray?.count == 1) {
                defaultNotificationCenter().post(name: Notification.Name.Cell.SelectNotiKey, object: NSNumber.init(value: true))
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
        let name = model.backupRoot ? model.bname ?? model.name ?? "" : model.name ?? ""
        if (selectFilesArray?.contains(where:{$0.uuid == model.uuid}))! && (selectFilesArray?.contains(where:{$0.name == name}))!{
            synced(self) {
                let index = selectFilesArray?.index(where: {$0.uuid == model.uuid && $0.name == name})
                if index != nil{
                    selectFilesArray?.remove(at: index!)
                }
                if (selectFilesArray?.count == 0) {
                    defaultNotificationCenter().post(name: Notification.Name.Cell.SelectNotiKey, object: NSNumber.init(value: false))
                }
            }
        }
    }
    
    private func removeTrueFiles(model:EntriesModel){
        
    }
    
    func removeAllSelectFiles(){
        synced(self) {
            selectFilesArray?.removeAll()
        }
    }
}
