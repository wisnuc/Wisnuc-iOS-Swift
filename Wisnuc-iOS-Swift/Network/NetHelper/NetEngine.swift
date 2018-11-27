//
//  NetEngine.swift
//  FruitMix-Swift
//
//  Created by wisnuc-imac on 2018/3/21.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Alamofire

typealias FormDataErrorHandler = (Error) -> (Void)
typealias NetworkResonseJSONCompletionHandler = (DataResponse<Any>) -> Void
typealias NetworkResonseDataCompletionHandler = (DataResponse<Data>) -> Void
typealias NetworkResonseStringCompletionHandler = (DataResponse<String>) -> Void

class NetEngine: NSObject {
    let urlPlaceholder = "http://"
    var manager:SessionManager?
    static let sharedInstance = NetEngine()
    private override init(){
        super.init()
    }
    
    var requestsRecordDic:Dictionary<String,DataRequest> = Dictionary.init()
    let cofig = RequestConfig.sharedInstance
    func addNormalRequetJOSN(requestObj:BaseRequest ,_ requestCompletionHandler:@escaping NetworkResonseJSONCompletionHandler){
        let baseRequsetObject = requestObj
        
        let requestURL = bulidRequestURL(request: requestObj)
        var requestParameters:RequestParameters = [:]
        var requestHTTPHeaders:RequestHTTPHeaders = [:]
        if baseRequsetObject.requestParameters() != nil {
            requestParameters = baseRequsetObject.requestParameters()!
        }
        if baseRequsetObject.requestHTTPHeaders() != nil {
            requestHTTPHeaders = baseRequsetObject.requestHTTPHeaders()!
        }
        
        var originalRequest: URLRequest?
        do {
            originalRequest = try URLRequest(url: URL.init(string: requestURL ?? urlPlaceholder)! , method: baseRequsetObject.requestMethod(), headers: requestHTTPHeaders)
            originalRequest?.timeoutInterval = baseRequsetObject.timeoutIntervalForRequest()
            let encodedURLRequest = try baseRequsetObject.requestEncoding().encode(originalRequest!, with: requestParameters)
            let request = Alamofire.request(encodedURLRequest).validate().responseJSON(completionHandler: requestCompletionHandler)
            baseRequsetObject.task = request.task
            baseRequsetObject.dataRequest = request
            addRecord(request: request)
        } catch {
            requestCompletionHandler(DataResponse<Any>.init(request: nil, response: nil, data: nil, result: Result<Any>.failure(BaseError.init(localizedDescription: LocalizedString(forKey: "无法创建请求"), code: ErrorCode.Network.CannotBuidRequest))))
        }
    }
    
    func addNormalRequetData(requestObj:BaseRequest ,_ requestCompletionHandler:@escaping NetworkResonseDataCompletionHandler){
        let baseRequsetObject = requestObj
        
        let requestURL = bulidRequestURL(request: requestObj)
        var requestParameters:RequestParameters = [:]
        var requestHTTPHeaders:RequestHTTPHeaders = [:]
        if baseRequsetObject.requestParameters() != nil {
            requestParameters = baseRequsetObject.requestParameters()!
        }
        if baseRequsetObject.requestHTTPHeaders() != nil {
            requestHTTPHeaders = baseRequsetObject.requestHTTPHeaders()!
        }
        var originalRequest: URLRequest?
        do {
            originalRequest = try URLRequest(url: URL.init(string: requestURL ?? urlPlaceholder)! , method: baseRequsetObject.requestMethod(), headers: requestHTTPHeaders)
            originalRequest?.timeoutInterval = baseRequsetObject.timeoutIntervalForRequest()
            let encodedURLRequest = try baseRequsetObject.requestEncoding().encode(originalRequest!, with: requestParameters)
            let request = Alamofire.request(encodedURLRequest).validate().responseData(completionHandler: requestCompletionHandler)
            baseRequsetObject.task = request.task
            baseRequsetObject.dataRequest = request
            addRecord(request: request)
        } catch {
            requestCompletionHandler(DataResponse<Data>.init(request: nil, response: nil, data: nil, result: Result<Data>.failure(BaseError.init(localizedDescription: LocalizedString(forKey: "无法创建请求"), code: ErrorCode.Network.CannotBuidRequest))))
        }
    }
    
    func addNormalRequetString(requestObj:BaseRequest ,_ requestCompletionHandler:@escaping NetworkResonseStringCompletionHandler){
        let baseRequsetObject = requestObj
        
        let requestURL = bulidRequestURL(request: requestObj)
        var requestParameters:RequestParameters = [:]
        var requestHTTPHeaders:RequestHTTPHeaders = [:]
        if baseRequsetObject.requestParameters() != nil {
            requestParameters = baseRequsetObject.requestParameters()!
        }
        if baseRequsetObject.requestHTTPHeaders() != nil {
            requestHTTPHeaders = baseRequsetObject.requestHTTPHeaders()!
        }
        var originalRequest: URLRequest?
        do {
            originalRequest = try URLRequest(url: URL.init(string: requestURL ?? urlPlaceholder)! , method: baseRequsetObject.requestMethod(), headers: requestHTTPHeaders)
            originalRequest?.timeoutInterval = baseRequsetObject.timeoutIntervalForRequest()
            let encodedURLRequest = try baseRequsetObject.requestEncoding().encode(originalRequest!, with: requestParameters)
            let request = Alamofire.request(encodedURLRequest).validate().responseString(completionHandler: requestCompletionHandler)
            baseRequsetObject.task = request.task
            baseRequsetObject.dataRequest = request
            addRecord(request: request)
        } catch {
            requestCompletionHandler(DataResponse<String>.init(request: nil, response: nil, data: nil, result: Result<String>.failure(BaseError.init(localizedDescription: LocalizedString(forKey: "无法创建请求"), code: ErrorCode.Network.CannotBuidRequest))))
        }
    }
    
    func addNormalRequetJOSN(requestObj:BaseRequest ,queue: DispatchQueue?,_ requestCompletionHandler:@escaping NetworkResonseJSONCompletionHandler){
        let baseRequsetObject = requestObj

        let requestURL = bulidRequestURL(request: requestObj)
        var requestParameters:RequestParameters = [:]
        var requestHTTPHeaders:RequestHTTPHeaders = [:]
        if baseRequsetObject.requestParameters() != nil {
            requestParameters = baseRequsetObject.requestParameters()!
        }
        if baseRequsetObject.requestHTTPHeaders() != nil {
            requestHTTPHeaders = baseRequsetObject.requestHTTPHeaders()!
        }
        var originalRequest: URLRequest?
         do {
            originalRequest = try URLRequest(url: URL.init(string: requestURL ?? urlPlaceholder)! , method: baseRequsetObject.requestMethod(), headers: requestHTTPHeaders)
            originalRequest?.timeoutInterval = baseRequsetObject.timeoutIntervalForRequest()
            let encodedURLRequest = try baseRequsetObject.requestEncoding().encode(originalRequest!, with: requestParameters)
            let request = Alamofire.request(encodedURLRequest).validate().responseJSON(queue: queue, options: JSONSerialization.ReadingOptions.allowFragments, completionHandler: requestCompletionHandler)
            baseRequsetObject.task = request.task
            baseRequsetObject.dataRequest = request
            addRecord(request: request)
         } catch {
            requestCompletionHandler(DataResponse<Any>.init(request: nil, response: nil, data: nil, result: Result<Any>.failure(BaseError.init(localizedDescription: LocalizedString(forKey: "无法创建请求"), code: ErrorCode.Network.CannotBuidRequest))))
        }
    }
    
    func addFormDataRequetJOSN(requestObj:BaseRequest ,queue: DispatchQueue? = nil,multipartFormData:@escaping (MultipartFormData) -> Void,_ requestCompletionHandler:@escaping NetworkResonseJSONCompletionHandler,errorHandler:@escaping FormDataErrorHandler){
        let baseRequsetObject = requestObj
        
        let requestURL = bulidRequestURL(request: requestObj)
        var requestParameters:RequestParameters = [:]
        var requestHTTPHeaders:RequestHTTPHeaders = [:]
        if baseRequsetObject.requestParameters() != nil {
            requestParameters = baseRequsetObject.requestParameters()!
        }
        if baseRequsetObject.requestHTTPHeaders() != nil {
            requestHTTPHeaders = baseRequsetObject.requestHTTPHeaders()!
        }
        var originalRequest: URLRequest?
        do {
            originalRequest = try URLRequest(url: URL.init(string: requestURL ?? urlPlaceholder)! , method: baseRequsetObject.requestMethod(), headers: requestHTTPHeaders)
            originalRequest?.timeoutInterval = baseRequsetObject.timeoutIntervalForRequest()
            let encodedURLRequest = try baseRequsetObject.requestEncoding().encode(originalRequest!, with: requestParameters)
            Alamofire.upload(multipartFormData: multipartFormData, with: encodedURLRequest) { [weak self](encodingResult) in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.validate(statusCode: 200..<500)
                    upload.responseJSON(queue: queue, options: JSONSerialization.ReadingOptions.allowFragments, completionHandler: requestCompletionHandler)
                    let request = upload
                    baseRequsetObject.task = request.task
                    baseRequsetObject.dataRequest = request
                    self?.addRecord(request: request)
                case .failure(let error):
                    errorHandler(error)
                }
            
            }
            
        } catch {
            requestCompletionHandler(DataResponse<Any>.init(request: nil, response: nil, data: nil, result: Result<Any>.failure(BaseError.init(localizedDescription: LocalizedString(forKey: "无法创建请求"), code: ErrorCode.Network.CannotBuidRequest))))
        }
    }
    
    func addUpload(requestObj:BaseRequest ,data:Data,queue: DispatchQueue? = nil,_ requestCompletionHandler:@escaping NetworkResonseJSONCompletionHandler){
        let baseRequsetObject = requestObj
        
        let requestURL = bulidRequestURL(request: requestObj)
        var requestHTTPHeaders:RequestHTTPHeaders = [:]
        if baseRequsetObject.requestHTTPHeaders() != nil {
            requestHTTPHeaders = baseRequsetObject.requestHTTPHeaders()!
        }
        var originalRequest: URLRequest?
        do {
            originalRequest = try URLRequest(url: URL.init(string: requestURL ?? urlPlaceholder)! , method: baseRequsetObject.requestMethod(), headers: requestHTTPHeaders)
            originalRequest?.timeoutInterval = baseRequsetObject.timeoutIntervalForRequest()
            let request = Alamofire.upload(data, with: originalRequest!).validate().responseJSON(queue: queue, options: JSONSerialization.ReadingOptions.allowFragments, completionHandler: requestCompletionHandler)
//            request(encodedURLRequest).validate().responseJSON(queue: queue, options: JSONSerialization.ReadingOptions.allowFragments, completionHandler: requestCompletionHandler)
            baseRequsetObject.task = request.task
            baseRequsetObject.dataRequest = request
            addRecord(request: request)
        } catch {
            requestCompletionHandler(DataResponse<Any>.init(request: nil, response: nil, data: nil, result: Result<Any>.failure(BaseError.init(localizedDescription: LocalizedString(forKey: "无法创建请求"), code: ErrorCode.Network.CannotBuidRequest))))
        }
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
    
    func cancleRequest(request:DataRequest?){
        if request != nil && request?.task != nil{
            request?.task?.cancel()
        }
        
        if request != nil{
            removeRecord(request: request!)
        }
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
                if let index = requestsRecordDic.index(forKey: key){
                    requestsRecordDic.remove(at: index)
                }
            }
        }
    }
    
    func requestHashKey(task:URLSessionTask) -> String{
        let key = "\(task.hash)"
        return key
    }
    
    // 合成 全的网址
    func bulidRequestURL(request:BaseRequest) -> String?{
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
        return  baseURL == nil ? nil : "\(String(describing: baseURL!))\(String(describing: detailURL))"
    }
}

