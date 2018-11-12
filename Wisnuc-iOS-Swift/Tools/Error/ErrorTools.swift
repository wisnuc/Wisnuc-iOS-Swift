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
        
        return message
    }
}
