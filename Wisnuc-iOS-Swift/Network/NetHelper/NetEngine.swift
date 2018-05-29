//
//  NetEngine.swift
//  FruitMix-Swift
//
//  Created by wisnuc-imac on 2018/3/21.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

typealias NetworkResonseJSONCompletionHandler = (DataResponse<Any>) -> Void
typealias NetworkResonseDataCompletionHandler = (DataResponse<Data>) -> Void
typealias NetworkResonseStringCompletionHandler = (DataResponse<String>) -> Void

class NetEngine: NSObject {
    static let sharedInstance = NetEngine()
    private override init(){
        super.init()
    }
    
    var requestsRecordDic:Dictionary<String,DataRequest> = Dictionary.init()
    let cofig = RequestConfig.sharedInstance
    func addNormalRequetJOSN(requestObj:BaseRequest ,_ requestCompletionHandler:@escaping NetworkResonseJSONCompletionHandler){
        let manager = Alamofire.SessionManager.default
        let baseRequsetObject = requestObj
        
        manager.session.configuration.timeoutIntervalForRequest =  baseRequsetObject.timeoutIntervalForRequest()
        let requestURL = bulidRequestURL(request: requestObj)
        var requestParameters:RequestParameters = [:]
        var requestHTTPHeaders:RequestHTTPHeaders = [:]
        if baseRequsetObject.requestParameters() != nil {
            requestParameters = baseRequsetObject.requestParameters()!
        }
        if baseRequsetObject.requestHTTPHeaders() != nil {
            requestHTTPHeaders = baseRequsetObject.requestHTTPHeaders()!
        }
        let request = manager.request(requestURL, method:baseRequsetObject.requestMethod() , parameters: requestParameters, encoding: baseRequsetObject.requestEncoding(), headers: requestHTTPHeaders).responseJSON(queue: <#T##DispatchQueue?#>, options: <#T##JSONSerialization.ReadingOptions#>, completionHandler: <#T##(DataResponse<Any>) -> Void#>)
        request.validate()
        baseRequsetObject.task = request.task
        addRecord(request: request)
    }
    
    func addNormalRequetData(requestObj:BaseRequest ,_ requestCompletionHandler:@escaping NetworkResonseDataCompletionHandler){
        let manager = Alamofire.SessionManager.default
        let baseRequsetObject = requestObj
        manager.session.configuration.timeoutIntervalForRequest =  baseRequsetObject.timeoutIntervalForRequest()
        let requestURL = bulidRequestURL(request: requestObj)
        
        var requestParameters:RequestParameters = [:]
        var requestHTTPHeaders:RequestHTTPHeaders = [:]
        if baseRequsetObject.requestParameters() != nil {
            requestParameters = baseRequsetObject.requestParameters()!
        }
        if baseRequsetObject.requestHTTPHeaders() != nil {
            requestHTTPHeaders = baseRequsetObject.requestHTTPHeaders()!
        }
        let request = manager.request(requestURL, method:baseRequsetObject.requestMethod() , parameters: requestParameters, encoding: baseRequsetObject.requestEncoding(), headers: requestHTTPHeaders).responseData(completionHandler: requestCompletionHandler)
        request.validate()
        baseRequsetObject.task = request.task
        addRecord(request: request)
    }
    
    func addNormalRequetString(requestObj:BaseRequest ,_ requestCompletionHandler:@escaping NetworkResonseStringCompletionHandler){
        let manager = Alamofire.SessionManager.default
        let baseRequsetObject = requestObj
        manager.session.configuration.timeoutIntervalForRequest =  baseRequsetObject.timeoutIntervalForRequest()
        let requestURL = bulidRequestURL(request: requestObj)

        var requestParameters:RequestParameters = [:]
        var requestHTTPHeaders:RequestHTTPHeaders = [:]
        if baseRequsetObject.requestParameters() != nil {
            requestParameters = baseRequsetObject.requestParameters()!
        }
        if baseRequsetObject.requestHTTPHeaders() != nil {
            requestHTTPHeaders = baseRequsetObject.requestHTTPHeaders()!
        }
        
        let request = manager.request(requestURL, method:baseRequsetObject.requestMethod() , parameters: requestParameters, encoding: baseRequsetObject.requestEncoding(), headers: requestHTTPHeaders).responseString(completionHandler: requestCompletionHandler)
        request.validate()
        baseRequsetObject.task = request.task
        addRecord(request: request)
    }
    

    //增加一条记录
    func addRecord(request:DataRequest){
        if request.task != nil{
            let key = requestHashKey(task: request.task!)
            synced(self) {
              requestsRecordDic[key] = request;
            }
        }
    }
    
    func cancleRequest(request:DataRequest){
        if request.task != nil{
            request.task?.cancel()
        }
        removeRecord(request: request)
    }
    
    func cancleAllRequest(){
    let copyRecord = requestsRecordDic
        for key in copyRecord.keys {
            let request = copyRecord[key]
            request?.cancel()
        }
        requestsRecordDic.removeAll()
    }
    
    func removeRecord(request:DataRequest){
        if request.task != nil{
            let key = requestHashKey(task: request.task!)
            synced(self) {
                let index = requestsRecordDic.index(forKey: key)
                requestsRecordDic.remove(at: index!)
            }
        }
    }
    
    func requestHashKey(task:URLSessionTask) -> String{
        let key = "\(task.hash)"
        return key
    }
    
    // 合成 全的网址
    func bulidRequestURL(request:BaseRequest) -> String{
        let detailURL = request.requestURL()
        if detailURL.hasPrefix("http") || detailURL.hasPrefix("https"){
            return detailURL
        }
        var baseURL:String!
        if request.useCDN(){
            if request.cdnURL().count>0{
                baseURL = request.cdnURL()
            }else{
                baseURL = cofig.cdnURL
            }
            
        }else{
            if request.baseURL().count>0{
                baseURL = request.baseURL()
            }else{
                baseURL = cofig.baseURL
            }
        }
        return "\(String(describing: baseURL!))\(String(describing: detailURL))"
    }
}

