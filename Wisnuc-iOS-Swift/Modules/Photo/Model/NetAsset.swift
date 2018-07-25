//
//  NetAsset.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/6.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import HandyJSON

class NetAsset: WSAsset,HandyJSON {
    var m:String?
    var h:Int?
    var w:Int?
    var size:Int?
    var orient:Int?
    var date:String?
    var make:String?
    var model:String?
    var lat:String?
    var latr:String?
    var fmlong:String?
    var longr:String?
    var fmhash:String?
    var rot:String?
    var dur:Float?
    
    required override init() {
        super.init()
    }
    
    func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.fmlong <-- "long"

        mapper <<<
            self.fmhash <-- "hash"
    }
    
    func didFinishMapping() {
        if !isNilString(self.date){
            let dateFormat =  DateFormatter.init()
            dateFormat.dateFormat = "yyyy:MM:dd HH:mm:ss"
            self.createDate = dateFormat.date(from: self.date!)
        }else{
            self.createDate = Date.init(timeIntervalSinceReferenceDate: 0)
        }
        
        if self.createDate == nil {
            self.createDate = Date.init(timeIntervalSinceReferenceDate: 0)
        }
    }
}
