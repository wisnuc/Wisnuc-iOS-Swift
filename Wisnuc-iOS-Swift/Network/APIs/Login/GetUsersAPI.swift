//
//  GetUsersAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/28.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

class GetUsersAPI: BaseRequest {
    var stationId:String?
    var token:String?
    init(stationId:String ,token:String) {
        super.init()
        self.stationId = stationId
        self.token = token
    }

    override func requestURL() -> String {
        return "\(kCloudBaseURL)stations/\(String(describing: stationId!))/json"
    }

    override func requestParameters() -> RequestParameters? {
        let requestUrl = "/users"
        let resource = requestUrl.toBase64()
        let dic = ["method":"GET","resource":resource]
        print(resource)
        return dic
    }

    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        let dic = ["Authorization":token!]
        return dic
    }
    
    override func requestEncoding() -> RequestParameterEncoding {
        return URLEncoding.queryString
    }
}
