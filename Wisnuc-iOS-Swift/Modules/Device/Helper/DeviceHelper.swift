//
//  DeviceHelper.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/30.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class DeviceHelper: NSObject {
    class func fetchInasdInfo(closure:(_ model:WinasdInfoModel)->()){
        let request = WinasdInfoAPI.init()
        request.startRequestJSONCompletionHandler { (response) in
            if let error = response.error{
                Message.message(text:error.localizedDescription)
            }else{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text:errorMessage)
                }else{
                    guard let dic = response.value as? NSDictionary else{
                        Message.message(text: LocalizedString(forKey: "error"))
                        return
                    }
                    let isLocal = AppNetworkService.networkState == .local ? true : false
                    var modelDic:NSDictionary = dic
                    if !isLocal{
                        if let dataDic = dic["data"] as? NSDictionary{
                            modelDic = dataDic
                        }
                    }
                    if let data = jsonToData(jsonDic: modelDic){
                        do{
                            let model = try JSONDecoder().decode(FilesStatsModel.self, from: data)
                            closure(model)
                        }catch{
                            
                        }
                    }
                }
            }
        }
    }
}
