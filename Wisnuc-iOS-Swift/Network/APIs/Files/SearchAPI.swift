//
//  SearchAPI.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/21.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class SearchAPI: BaseRequest {
//    order
//    string (optional) Example: newest
//    sort order
//
//    starti
//    string (optional) Example: 1528260514783.d00b3fa8-4028-41dd-8f72-e69a9cd6768d
//    time.uuid
//
//    starte
//    string (optional) Example: 1528260514783.d00b3fa8-4028-41dd-8f72-e69a9cd6768d
//    time.uuid
//
//    last
//    string (required) Example: 1.foo/alonzo church.jpg
//    iterator for query ordered by structure
//
//    count
//    number (optional) Example: 500
//    positive integer
//
//    places
//    string (required) Example: dd8b6213-f495-4001-9846-cbeeab4f8adb
//    directory uuid (may also be a drive uuid)
//
//    class
//    enum (optional) Example: image, video, audio, document
//    shortcut for types
//
//    types
//    string (optional) Example: JPEG.PNG.BMP.GIF
//    type or type list, separated by dot
//
//    tags
//    string (optional) Example: 1.2
//    tag or tag list, separated by dot
//
//    name
//    string (optional) Example: foo
//    name search
//
//    fileOnly
//    boolean (optional) Example: true
    var order:String?
    var starti:String?
    var starte:String?
    var last:String?
    var count:NSNumber?
    var places:String?
    var searchClass:String?
    var types:String?
    var tags:String?
    var name:String?
    var fileOnly:NSNumber?
    
    init(order:String? = nil ,starti:String? = nil, starte:String? = nil, last:String? = nil, count:NSNumber? = nil, places:String, `class`:String? = nil , types:String? = nil , tags:String? = nil, name:String? = nil, fileOnly:NSNumber? = nil) {
        self.order = order
        self.starti = starti
        self.starte = starte
        self.last = last
        self.count = count
        self.places = places
        self.searchClass = `class`
        self.types = types
        self.tags = tags
        self.name = name
        self.fileOnly = fileOnly
    }
    
    override func requestURL() -> String {
        switch AppNetworkService.networkState {
        case .normal?:
            return kCloudCommonJsonUrl
        case .local?:
            return "/files"
        default:
            return ""
        }
    }
    
    override func requestParameters() -> RequestParameters? {
        let dic:NSMutableDictionary?
        dic = NSMutableDictionary.init()
        dic?.setValue(order, forKey: "order")
        dic?.setValue(starti, forKey: "starti")
        dic?.setValue(starte, forKey: "starte")
        dic?.setValue(last, forKey: "last")
        dic?.setValue(count, forKey: "count")
        dic?.setValue(places, forKey: "places")
        dic?.setValue(searchClass, forKey: "class")
        dic?.setValue(types, forKey: "types")
        dic?.setValue(tags, forKey: "tags")
        dic?.setValue(name, forKey: "name")
        dic?.setValue(fileOnly, forKey: "fileOnly")
        return dic as? RequestParameters
    }
    
    override func requestHTTPHeaders() -> RequestHTTPHeaders? {
        switch AppNetworkService.networkState {
        case .normal?:
            return [kRequestAuthorizationKey:AppTokenManager.token!]
        case .local?:
            return [kRequestAuthorizationKey:JWTTokenString(token: AppTokenManager.token!)]
        default:
            return nil
        }
    }
}
