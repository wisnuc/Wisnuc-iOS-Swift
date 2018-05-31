//
//  AppService.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/23.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

let MainServices = AppService.sharedInstance
let AppUserService =  MainServices().userService

class AppService: NSObject,ServiceProtocol{
    var networkState:NetworkServiceState?{
        didSet{
            switch networkState {
            case .normal?:
                break
            case .local?:
                break
            default:
                break
            }
        }
    }
    
    private static var privateShared : AppService?
    class func sharedInstance() -> AppService { // change class to final to prevent override
        guard let uwShared = privateShared else {
            privateShared = AppService()
            return privateShared!
        }
        return uwShared
    }
    
    override init() {
        
    }
    
    func abort() {
        NetEngine.sharedInstance.cancleAllRequest()
        userService.abort()
        print("Disposed Singleton instance")
    }
    
    deinit {
       
    }
    
    func loginAction(model:CloadLoginUserRemotModel,orginTokenUser:User,complete:((_ error:Error?,_ user:User?)->())){
        if model.uuid == nil || isNilString(model.uuid){
            complete(LoginError(code: ErrorCode.Login.NoUUID, kind: LoginError.ErrorKind.LoginNoUUID, localizedDescription: LocalizedString(forKey: "UUID is not exist")), nil)
        }
        let user = AppUserService.createUser(uuid: model.uuid!)
        user.userName = model.username
        user.bonjour_name = model.name
        user.stationId = model.id
        user.cloudToken = orginTokenUser.cloudToken
        user.isFirstUser = NSNumber.init(value: model.isFirstUser!)
        user.isAdmin = NSNumber.init(value: model.isAdmin!)
        user.avaterURL = orginTokenUser.avaterURL
        user.isLocalLogin = NSNumber.init(value: false)

        if !isNilString(model.LANIP) {
            let urlString  = "http://\(String(describing: model.LANIP)):3000/"
            user.localAddr = urlString
        }
        
        
        complete(nil,user)
    }
    
    lazy var userService: UserService = {
        let service = UserService.init()
        return service
    }()
}
