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
    
    var name:String?
    var mtime:Double?
    var size:Int64?
    var uuid:String?
    var fmhash:String?
    var place:Int?
    var pdir:String?
    var namepath:NSArray?
    var metadata:HJMetadata?
    required override init() {
        super.init()
        self.type = WSAssetType.NetImage
    }
    
    func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.fmhash <-- "hash"
    }
    
    func didFinishMapping() {
        if !isNilString(self.metadata?.date){
            let dateFormat =  DateFormatter.init()
            dateFormat.dateFormat = "yyyy:MM:dd HH:mm:ss"
            dateFormat.timeZone = TimeZone.current
            self.createDate = dateFormat.date(from: (self.metadata?.date!)!)
        }else{
            self.createDate = Date.init(timeIntervalSinceReferenceDate: 0)
        }

        if self.createDate == nil {
            self.createDate = Date.init(timeIntervalSinceReferenceDate: 0)
        }
        
        if(!isNilString(self.metadata?.type) && kVideoTypes.contains((self.metadata?.type!)!)){
            self.type = WSAssetType.NetVideo
        }else if self.metadata?.type ==  FilesFormatType.GIF.rawValue {
            self.type = WSAssetType.GIF
        }
    }
}

class HJMetadata: HandyJSON {
    var date:String?
    var h:Float?
    var w:Float?
    var make:String?
    var model:String?
    var orient:Int?
    var type:String?
   
    required init() {}
}
