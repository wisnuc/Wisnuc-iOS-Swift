//
//  LoginCommonHelper.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/16.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import Foundation

class LoginCommonHelper: NSObject {
    struct Static
    {
        static var instance: LoginCommonHelper?
    }
    
    class var sharedInstance: LoginCommonHelper
    {
        if Static.instance == nil
        {
            Static.instance = LoginCommonHelper()
        }
        
        return Static.instance!
    }
    
    internal static let instance = LoginCommonHelper()
    
    func dispose()
    {
        LoginCommonHelper.Static.instance = nil
        print("LoginCommonHelper Disposed Singleton instance")
    }
    
    func stationAction(token:String,user:User,viewController:UIViewController,lastDeviceClosure:@escaping (_ user:User,_ stationModel:StationsInfoModel)->()) {
        self.getStations(token: token, closure: { [weak self](error, models,lastSn) in
            if error == nil{
                if let models = models{
                    if models.count > 0{
                        if let lastSn = lastSn{
                            guard let model = models.first(where: {$0.sn == lastSn}) else{
                                self?.selectStation(models: models, user: user, viewController: viewController)
                                return
                            }
                            guard let online = model.online else{
                                self?.selectStation(models: models, user: user, viewController: viewController)
                                return
                            }
                            if online == 1{
                                lastDeviceClosure(user,model)
                            }else{
                                self?.selectStation(models: models, user: user, viewController: viewController)
                            }
                        }else{
                          self?.selectStation(models: models, user: user, viewController: viewController)
                        }
                    }else{
                        let cofigVC = FirstConfigViewController.init(style: NavigationStyle.whiteWithoutShadow,user:user)
                        if viewController is LoginRootViewController{
                          let navi = UINavigationController.init(rootViewController: cofigVC)
                            viewController.present(navi, animated: true, completion: {
                                
                            })
                          return
                        }
                        
                        cofigVC.modalTransitionStyle = .coverVertical
                        viewController.navigationController?.pushViewController(cofigVC, animated: true)
                    }
                }
                print(models as Any)
            }else{
                switch error{
                case is LoginError :
                    let loginError = error as! LoginError
                    if loginError.kind == LoginError.ErrorKind.LoginNoBindDevice || loginError.kind == LoginError.ErrorKind.LoginNoOnlineDevice || loginError.kind == LoginError.ErrorKind.LoginRequestError {
                        Message.message(text: LocalizedString(forKey: loginError.localizedDescription), duration:2.0)
                    }else  {
                        Message.message(text: LocalizedString(forKey:"\(String(describing: loginError.localizedDescription))"),duration:2.0)
                    }
                case is BaseError :
                    let baseError = error as! BaseError
                    Message.message(text: LocalizedString(forKey:"\(String(describing: baseError.localizedDescription))"),duration:2.0)
                default:
                    Message.message(text: LocalizedString(forKey:"\(String(describing: (error?.localizedDescription)!))"),duration:2.0)
                }
                ActivityIndicator.startActivityIndicatorAnimation()
                print(error as Any)
            }
        })
    }
    
    func selectStation(models:[StationsInfoModel],user:User,viewController:UIViewController){
        let deviceViewController = LoginSelectionDeviceViewController.init(style: .whiteWithoutShadow,devices:models,user:user)
        deviceViewController.delegate = viewController as? LoginSelectionDeviceViewControllerDelegte
        let navigationController =  UINavigationController.init(rootViewController: deviceViewController)
        viewController.present(navigationController, animated: true) {
            
        }
    }
    
    func getStations(token:String?,closure: @escaping (Error?,[StationsInfoModel]?,_ lastSn:String?) -> Void){
        let requset = GetStationsAPI.init(token: token ?? "")
        requset.startRequestJSONCompletionHandler({ (response) in
            ActivityIndicator.stopActivityIndicatorAnimation()
            if response.error == nil{
                if response.result.value != nil {
                    let rootDic = response.result.value as! NSDictionary
                    let code = rootDic["code"] as! NSNumber
                    let message = rootDic["message"] as! NSString
                    if code.intValue != 1 && code.intValue > 200 {
                        return  closure(LoginError.init(code: Int(code.int64Value), kind: LoginError.ErrorKind.LoginRequestError, localizedDescription: message as String), nil,nil)
                    }
                    if let dataDic = rootDic["data"] as? NSDictionary{
                        var resultArray:[StationsInfoModel] = Array.init()
                        if let ownStations =  dataDic["ownStations"] as? [NSDictionary]{
                            var ownStationArray:[StationsInfoModel] = Array.init()
                            for value in ownStations{
                                do {
                                    if let data =  jsonToData(jsonDic: value){
                                        var model = try JSONDecoder().decode(StationsInfoModel.self, from:  data)
                                        model.isShareStation = false
                                        ownStationArray.append(model)
                                    }
                                }catch{
                                    return  closure(BaseError(localizedDescription: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail, code: ErrorCode.JsonModel.SwitchTOModelFail),nil,nil)
                                }
                            }
                            resultArray.append(contentsOf: ownStationArray)
                        }
                        if let sharedStations =  dataDic["sharedStations"] as? [NSDictionary]{
                            var sharedStationArray:[StationsInfoModel] = Array.init()
                            for value in sharedStations{
                                do {
                                    if let data =  jsonToData(jsonDic: value){
                                        var model = try JSONDecoder().decode(StationsInfoModel.self, from:  data)
                                        model.isShareStation = true
                                        sharedStationArray.append(model)
                                    }
                                }catch{
                                    return  closure(BaseError(localizedDescription: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail, code: ErrorCode.JsonModel.SwitchTOModelFail),nil,nil)
                                }
                            }
                            resultArray.append(contentsOf:sharedStationArray)
                        }
                        
                        var lastSn:String?
                        if let lastUseDeviceSn =  dataDic["lastUseDeviceSn"] as? String{
                           lastSn = lastUseDeviceSn
                        }
                        return closure(nil,resultArray,lastSn)
                    }
                }
            }else{
                return closure(response.error,nil,nil)
            }
        })
    }
}
