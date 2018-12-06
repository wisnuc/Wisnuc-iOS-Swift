//
//  PhotoHelper.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/12/4.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class PhotoHelper: NSObject {
    class func requestImageUrl(size:CGSize? = nil,hash:String)->URL?{
        let detailURL = "media"
        let holdPlaceSize:CGFloat = 200
        let frameWidth:Int = Int(size?.width ?? holdPlaceSize)
        let frameHeight:Int = Int(size?.height ?? holdPlaceSize)
        let resource = "/media/\(hash)"
        let param = "\(kRequestImageAltKey)=\(kRequestImageThumbnailValue)&\(kRequestImageWidthKey)=\(String(describing: frameWidth))&\(kRequestImageHeightKey)=\(String(describing: frameHeight))&\(kRequestImageModifierKey)=\(kRequestImageCaretValue)&\(kRequestImageAutoOrientKey)=true"
        
        let params:[String:String] = [kRequestImageAltKey:kRequestImageThumbnailValue,kRequestImageWidthKey:String(describing: frameWidth),kRequestImageHeightKey:String(describing: frameHeight),kRequestImageModifierKey:kRequestImageCaretValue,kRequestImageAutoOrientKey:"true"]
        let dataDic = [kRequestUrlPathKey:resource,kRequestVerbKey:RequestMethodValue.GET,"params":params] as [String : Any]
        guard let data = jsonToData(jsonDic: dataDic as NSDictionary) else {
            return nil
        }
        
        guard let dataString = String.init(data: data, encoding: .utf8) else {
            return nil
        }
        
        guard let urlString = String.init(describing:"\(kCloudBaseURL)\(kCloudCommonPipeUrl)?data=\(dataString)").addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return nil
        }
        
        guard  let normalUrl = URL.init(string:urlString) else {
            return nil
        }
        //                req.addValue(dataString, forHTTPHeaderField: kRequestImageDataValue)
        guard let url = AppNetworkService.networkState == .local ? URL.init(string: "\(RequestConfig.sharedInstance.baseURL!)/\(detailURL)/\(hash)?\(param)") : normalUrl else {
            return nil
        }
        return url
    }
    
    class func fetchPhotoTime(model:NetAsset?)->TimeInterval?{
        guard let emodel = model else{
            return nil
        }
        if  emodel.mtime != nil, let date =  emodel.metadata?.date,let datec = emodel.metadata?.datec{
            guard let datacTimeInterval = TimeTools.dateTimeIntervalUTC(datec),let dataTimeInterval = TimeTools.dateTimeIntervalUTC(date) else{
                return TimeInterval(emodel.mtime!/1000)
            }
            
            if let datacTimeInterval = TimeTools.dateTimeIntervalUTC(datec),TimeTools.dateTimeIntervalUTC(date) == nil{
                return datacTimeInterval
            }
            
            if let dataTimeInterval = TimeTools.dateTimeIntervalUTC(date),TimeTools.dateTimeIntervalUTC(datec) == nil{
                return dataTimeInterval
            }
            
            return  dataTimeInterval > datacTimeInterval ?  dataTimeInterval : datacTimeInterval
        }else if  emodel.mtime != nil, let date = emodel.metadata?.date ,emodel.metadata?.datec == nil{
            if let dataTimeInterval = TimeTools.dateTimeIntervalUTC(date){
                return dataTimeInterval
            }else{
                return TimeInterval(emodel.mtime!/1000)
            }
        }else if  let mtime = emodel.mtime{
            return TimeInterval(mtime/1000)
        }
        
        return  nil
    }
}
