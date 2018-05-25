//
//  AppService.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/23.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

let MainServices = AppService.sharedInstance
let AppUserService =  MainServices.userService

class AppService: NSObject {

    static let sharedInstance = AppService()
    private override init(){
        super.init()
    }
    
    lazy var userService: UserService = {
        let service = UserService.init()
        return service
    }()
}
