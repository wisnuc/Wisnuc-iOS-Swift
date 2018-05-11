//
//  FilesHelper.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/10.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class FilesHelper: NSObject {
    var chooseFilesArray:Array<FilesModel>?
    static let sharedInstance = FilesHelper()
    private override init(){
       super.init()
       chooseFilesArray = []
    }
    
    func addChooseFiles(model:FilesModel){
    //互斥锁
    objc_sync_enter(self)
    chooseFilesArray?.append(model)
    objc_sync_exit(self)
    }
}
