//
//  PhotoTools.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/30.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class PhotoTools: NSObject {
  class func getSize(model:WSAsset) -> CGSize{
        
        var w:CGFloat = 0
        var h:CGFloat = 0
        
        if((model.asset) != nil){
            w = MIN(x: CGFloat(model.asset!.pixelWidth), y: __kWidth)
            h = w * CGFloat((model.asset?.pixelHeight)!) / CGFloat((model.asset?.pixelWidth)!)
        }else{
            w = MIN(x: CGFloat(((model as! NetAsset).metadata?.w!)!), y: __kWidth)
            h = w * CGFloat(((model as! NetAsset).metadata?.h)!) / CGFloat(((model as! NetAsset).metadata?.w!)!)
        }
        
        if h.isNaN{
            return CGSize.zero
        }
        
        if h > __kHeight || h.isNaN {
            h = __kHeight
            w = (model.asset != nil) ? h * CGFloat(model.asset!.pixelWidth) / CGFloat(model.asset!.pixelHeight)
                : h * CGFloat(((model as! NetAsset).metadata?.w!)!)  / CGFloat(((model as! NetAsset).metadata?.w!)!)
        }
        
        return CGSize(width: w, height: h)
    }
    

    class func getMouthDateString(date:Date) -> String{
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy年MM月"
        var dateString = formatter.string(from: date)
        if dateString == "1970年01月" {
            dateString = "未知时间"
        }
        return dateString
    }
    
    class func getDateString(date:Date) -> String{
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        return dateString
    }
}
