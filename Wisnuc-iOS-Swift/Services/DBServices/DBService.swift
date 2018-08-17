//
//  DBService.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/8/17.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MagicalRecord

class DBService: NSObject ,ServiceProtocol{
    func abort() {
        
    }
    
    lazy var saveQueue: DispatchQueue = {
        let queue = DispatchQueue.init(label: "com.wisnuc.save")
         DispatchQueue.global(qos: .default).setTarget(queue: queue)
        return queue
    }()

    lazy var saveContext = NSManagedObjectContext.mr_newMainQueue()
    
    lazy var createContext = NSManagedObjectContext.mr_context(withParent: self.saveContext)
}
