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
        let holdPlaceSize:CGFloat = 186
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
    
    class func searchAny(places:String? = nil,text:String? = nil,types:String? = nil,sClass:String? = nil,complete:@escaping (_ mdoels: [NetAsset]?,_ error:Error?)->()){
        var array:Array<NetAsset> =  Array.init()
        var order:String?
        
        order = !isNilString(types) || !isNilString(sClass) ? nil : SearhOrder.newest.rawValue
        var place = places
        if places == nil{
            var placesArray:Array<String> = Array.init()
            if let uuid = AppUserService.currentUser?.userHome{
                placesArray.append(uuid)
            }
            let placesPlaceholder = placesArray.joined(separator: ".")
            place = placesPlaceholder
        }
        let request = SearchAPI.init(order:order, places: place!,class:sClass, types:types, name:text)
        request.startRequestJSONCompletionHandler { (response) in
            if response.error == nil{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    let error = NSError(domain: response.response?.url?.absoluteString ?? "", code: ErrorCode.Request.CloudRequstError, userInfo: [NSLocalizedDescriptionKey:errorMessage])
                    return complete(nil,error)
                }
                let isLocalRequest = AppNetworkService.networkState == .local
                let result = (isLocalRequest ? response.value as? NSArray : (response.value as! NSDictionary)["data"]) as? NSArray
                if result != nil{
                    let rootArray = result
                    for (_ , value) in (rootArray?.enumerated())!{
                        if value is NSDictionary{
                            let dic = value as! NSDictionary
                            let model = NetAsset.init(dict:dic)
                            array.append(model)
                        }
                    }
                    return complete(array,nil)
                }
            }else{
                return complete(nil,response.error)
            }
        }
    }

    class func sort(_ assetsArray:Array<WSAsset>,clousure:@escaping (_ sortedAssets:Array<WSAsset>,_ dataSouce:Array<Array<WSAsset>>)->()){
        autoreleasepool {
            DispatchQueue.global(qos: .default).async {
            let start = CFAbsoluteTimeGetCurrent();
            var array:Array<WSAsset>  = Array.init()
            array.append(contentsOf: assetsArray)
                  let s = CFAbsoluteTimeGetCurrent();
                array = array.filter({$0.createDate != nil})
                array.sort(by: {$0.createDate!>$1.createDate!})
                let l = CFAbsoluteTimeGetCurrent();
                print("😆\(l - s)")
            let timeArray:NSMutableArray = NSMutableArray.init()
            let photoGroupArray:NSMutableArray = NSMutableArray.init()
            if array.count>0 {
                let firstAsset = array.first
                firstAsset?.indexPath = IndexPath.init(row: 0, section: 0)
                let photoDateGroup1:NSMutableArray = NSMutableArray.init() //第一组照片
                photoDateGroup1.add(firstAsset!)
                photoGroupArray.add(photoDateGroup1)
                if firstAsset?.createDate != nil{
                    timeArray.add(firstAsset!.createDate!)
                }
                if array.count == 1{
                    let dataSouce = photoGroupArray as! Array<Array<WSAsset>>
                    return clousure(array,dataSouce)
                }
                var photoDateGroup2:NSMutableArray? = photoDateGroup1 //最近的一组
              
                for i in 1..<array.count {
                    let photo1 =  array[i]
                    let photo2 = array[i-1]
                    if Calendar.current.isDate(photo1.createDate! , inSameDayAs: photo2.createDate!){
                        photo1.indexPath = IndexPath.init(row: ((photoGroupArray[photoGroupArray.count - 1]) as! NSMutableArray).count, section: photoGroupArray.count - 1)
                        photoDateGroup2!.add(photo1)
                    }else{
                        photo1.indexPath = IndexPath.init(row: 0, section: photoGroupArray.count)
                        if photo1.createDate != nil{
                            timeArray.add(photo1.createDate!)
                        }
                        photoDateGroup2 = nil
                        photoDateGroup2 = NSMutableArray.init()
                        photoDateGroup2!.add(photo1)
                        photoGroupArray.add(photoDateGroup2!)
                    }
                }

            }
                let last = CFAbsoluteTimeGetCurrent()
                print("🌶\(last - start)")
                let dataSouce = photoGroupArray as! Array<Array<WSAsset>>
                DispatchQueue.main.async {
                 return clousure(array,dataSouce)
                }
            }
        }
       
    }
}
