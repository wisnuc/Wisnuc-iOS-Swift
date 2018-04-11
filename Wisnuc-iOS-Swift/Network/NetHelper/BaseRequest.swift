//
//  BaseRequest.swift
//  FruitMix-Swift
//
//  Created by wisnuc-imac on 2018/3/21.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

enum RequestMethodType:Int{
   case get = 0
   case post
   case head
   case put
   case delete
   case patch
}

class BaseRequest: NSObject {
    func requestMethod() -> RequestMethodType {
        return .get
    }
    
    func start(){
        Alamofire.request("", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if response.result.isSuccess{
                print(response.result.value ?? [String :AnyObject]())
//                finished(response.result.valueas? [String : AnyObject],nil)
            }else{
//                finished(nil,response.result.erroras NSError?)
            }
        }
    }
}
