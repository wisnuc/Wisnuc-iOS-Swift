//
//  ErrorTools.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/12.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import Foundation
class ErrorTools: NSObject {
    class func responseErrorData(_ data:Data?) -> String?{
        guard let errorData = data else {
            return nil
        }
        
        guard let errorDict =  dataToNSDictionary(data:errorData) else{
            return nil
        }
        
        guard let message =  errorDict["message"] as? String else{
            return nil
        }
        
        guard let code =  errorDict["code"] else{
            return nil
        }
        
        if (code as? Int) == 1 || message == "ok"{
            return nil
        }
        return message
    }
    
    class func dictResponseErrorData(_ data:Data?) -> [String:Any?]?{
        guard let errorData = data else {
            return nil
        }
        
        guard let errorDict =  dataToNSDictionary(data:errorData) else{
            return nil
        }
        
        guard let message =  errorDict[kRequestResponseMessageKey] as? String else{
            return nil
        }
        
        guard let code =  errorDict[kRequestResponseCodeKey] else{
            return nil
        }
        
        if (code as? Int) == 1 || message == "ok"{
            return nil
        }
        let dict = [kRequestResponseCodeKey:code,kRequestResponseMessageKey:message]
        return dict
    }
}

