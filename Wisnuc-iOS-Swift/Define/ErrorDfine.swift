//
//  ErrorDfine.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/30.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation

struct ErrorCode {
    struct Login {
        public static let NoBindDevice:Int = 50001
        public static let NoUserExist:Int = 50002
        public static let NoUUID:Int = 50003
        public static let NotLogin:Int = 50004
        public static let NoToken:Int = 50005
        public static let NoUserHome:Int = 50006
    }
    
    struct Network {
        public static let NotConnect:Int = 40004
    
    }
    
    struct JsonModel {
        public static let SwitchTOModelFail:Int = 60001
    }
}


struct LoginError: Error,Equatable{
    enum ErrorKind {
        case LoginPasswordWrong
        case LoginNoUUID
        case LoginNoBindDevice
        case LoginNoOnlineDevice
        case LoginNoBindUser
        case LoginRequestError
        case LoginFailure
        case LoginNoToken
        case LoginNoUserHome
    }
    
    let code: Int
    let kind: ErrorKind
    let localizedDescription: String
}

struct BaseError:Error {
    var localizedDescription: String
    var code: Int
}


struct ErrorLocalizedDescription{
    struct Login {
        public static let NoCurrentUser = "User Not Found"
        public static let NoToken = "No Token"
        public static let NotLogin = "User Not Login"
        public static let NoUserHome = "User Home Not Found"
    }
    
    struct JsonModel {
        public static let SwitchTOModelFail = "Json to Model error"
    }
}

