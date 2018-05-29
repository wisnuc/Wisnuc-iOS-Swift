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
        let requestUrl = "/user"
        let resource = requestUrl.toBase64()
        let dic = ["method":"GET","resource":"L3VzZXJz"]
        return dic
    }

    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        let dic = ["Authorization":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjp7ImlkIjoiZmFkZTE2NGQtMTkxOS00ODMzLTg2YWYtNDcwODc5NmJjMjk2Iiwibmlja05hbWUiOiLlhYPlrZDmlLgiLCJhdmF0YXJVcmwiOiJodHRwOi8vdGhpcmR3eC5xbG9nby5jbi9tbW9wZW4vdmlfMzIvNFVPbXBvUzBjbjhOM2Y5b0k1U2ljQUtya3JJdkh0eFFwOEZGMDVSbkRyaWE0anNZbXFyU0ZVTEZsNDhBSHhZajY1UkJONWFWdnA1RkRTbWZpYmNPYnhWdkEvMTMyIn0sImV4cCI6MTUzMDE1NjY3MjEyNn0.0TkbUEQmTvVSoU8HddcYusrbbyfATl0oH4If6ofCu2s"]
        return dic
    }
    
    override func requestEncoding() -> RequestParameterEncoding {
        return URLEncoding.queryString
    }
}
