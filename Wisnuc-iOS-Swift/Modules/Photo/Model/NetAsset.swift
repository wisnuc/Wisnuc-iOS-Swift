//
//  NetAsset.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/6.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation

class NetAsset: WSAsset {
    var name:String?
    var mtime:Double?
    var size:Int64?
    var uuid:String?
    var fmhash:String?
    var place:Int?
    var pdir:String?
    var namepath:NSArray?
    var bname:String?
    var bctime:Int64?
    var bmtime:Int64?
    var otime:Int64?
    var metadata:HJMetadata?
    var netDate:Date?
    
    init(dict:NSDictionary) {
        super.init()
        self.type = WSAssetType.NetImage
        self.name = dict.object(forKey: "name") as? String
        self.mtime = dict.object(forKey: "mtime") as? Double
        self.size = dict.object(forKey: "size") as? Int64
        self.uuid = dict.object(forKey: "uuid") as? String
        self.fmhash = dict.object(forKey: "hash") as? String
        self.place = dict.object(forKey: "place") as? Int
        self.pdir = dict.object(forKey: "pdir") as? String
        self.namepath = dict.object(forKey: "namepath") as? NSArray
        self.bname = dict.object(forKey: "bname") as? String
        self.bctime = dict.object(forKey: "bctime") as? Int64
        self.bmtime = dict.object(forKey: "bmtime") as? Int64
        self.otime = dict.object(forKey: "otime") as? Int64
        
        if let metadataDic = dict.object(forKey: "metadata") as? NSDictionary{
            let metadata = HJMetadata.init(dict:metadataDic)
            self.metadata = metadata
        }
        
        
        if(!isNilString(self.metadata?.type) && kVideoTypes.contains((self.metadata?.type!)!)){
            self.type = WSAssetType.NetVideo
        }else if self.metadata?.type ==  FilesFormatType.GIF.rawValue {
            self.type = WSAssetType.GIF
        }
        
        self.netDate = Date.init(timeIntervalSince1970: PhotoHelper.fetchPhotoTime(model: self) ?? Date.init(timeIntervalSinceNow: 0).timeIntervalSince1970*1000)
    
//        if let fmhash = self.fmhash {
////            if let requestImageUrl = PhotoHelper.requestImageUrl(size: CGSize(width: 64, height: 64), hash: fmhash){
//            AppNetworkService.getThumbnailBackgroud(hash: fmhash, size: CGSize(width: 64, height: 64)) { (error, image, url) in
//            }
////            }
//        }
    }

//    required override init() {
//        super.init()
//        self.type = WSAssetType.NetImage
//    }
//
//    func mapping(mapper: HelpingMapper) {
//        mapper <<<
//            self.fmhash <-- "hash"
//    }
    
//    func didFinishMapping() {
//        if !isNilString(self.metadata?.date){
//            let dateFormat =  DateFormatter.init()
//            dateFormat.dateFormat = "yyyy:MM:dd HH:mm:ss"
//            dateFormat.timeZone = TimeZone.current
//            self.createDate = dateFormat.date(from: (self.metadata?.date!)!)
//        }else{
//            self.createDate = Date.init(timeIntervalSinceReferenceDate: 0)
//        }
//
//        if self.createDate == nil {
//            self.createDate = Date.init(timeIntervalSinceReferenceDate: 0)
//        }
        
//        if(!isNilString(self.metadata?.type) && kVideoTypes.contains((self.metadata?.type!)!)){
//            self.type = WSAssetType.NetVideo
//        }else if self.metadata?.type ==  FilesFormatType.GIF.rawValue {
//            self.type = WSAssetType.GIF
//        }
//    }
    
    
    override var hash: Int{//hashValue的实现
        return (self.fmhash?.hash)!
//            ^ self.mtime.hashValue ^ self.size.hashValue ^ self.uuid.hashValue ^ self.fmhash.hashValue ^ self.place.hashValue ^ self.pdir.hashValue ^ self.namepath.hashValue ^ self.bname.hashValue ^ self.bctime.hashValue ^ self.bmtime.hashValue ^ self.otime.hashValue ^ self.type.hashValue ^ self.metadata.hashValue
    }
    
    static func ==(m1:NetAsset,m2:NetAsset) -> Bool{
        return m1.fmhash == m2.fmhash
//            && m1.mtime == m2.mtime && m1.size == m2.size && m1.uuid == m2.uuid && m1.fmhash == m2.fmhash && m1.place == m2.place && m1.pdir == m2.pdir && m1.namepath == m2.namepath && m1.bname == m2.bname && m1.bctime == m2.bctime && m1.bmtime == m2.bmtime && m1.otime == m2.otime && m1.type == m2.type && m1.metadata == m2.metadata
    }
}
 

class HJMetadata:NSObject {
    var date:String?
    var h:Float?
    var w:Float?
    var make:String?
    var model:String?
    var orient:Int?
    var type:String?
    var datec:String?
    var localPath:String?
    var disabled:Bool?
    var status:String?
    var lastBackupTime:Int64?
    var dur:Double?
    
    init(dict:NSDictionary) {
        self.date = dict.object(forKey: "date") as? String
        self.h = dict.object(forKey: "h") as? Float
        self.w = dict.object(forKey: "w") as? Float
        self.make = dict.object(forKey: "make") as? String
        self.model = dict.object(forKey: "model") as? String
        self.type = dict.object(forKey: "type") as? String
        self.datec = dict.object(forKey: "datec") as? String
        self.localPath = dict.object(forKey: "localPath") as? String
        self.disabled = dict.object(forKey: "disabled") as? Bool
        self.status = dict.object(forKey: "status") as? String
        self.lastBackupTime = dict.object(forKey: "lastBackupTime") as? Int64
        self.dur = dict.object(forKey: "dur") as? Double
    }
    
    override var hash: Int{//hashValue的实现
        return self.date.hashValue ^ self.h.hashValue ^ self.w.hashValue ^ self.make.hashValue ^ self.model.hashValue ^ self.datec.hashValue ^ self.type.hashValue ^ self.localPath.hashValue ^ self.disabled.hashValue ^ self.status.hashValue ^ self.lastBackupTime.hashValue ^ self.dur.hashValue
    }
    
    static func ==(m1:HJMetadata,m2:HJMetadata) -> Bool{
        return m1.date == m2.date && m1.h == m2.h && m1.w == m2.w && m1.make == m2.make && m1.model == m2.model && m1.type == m2.type && m1.datec == m2.datec && m1.localPath == m2.localPath && m1.disabled == m2.disabled && m1.status == m2.status && m1.lastBackupTime == m2.lastBackupTime && m1.dur == m2.dur
    }
}
