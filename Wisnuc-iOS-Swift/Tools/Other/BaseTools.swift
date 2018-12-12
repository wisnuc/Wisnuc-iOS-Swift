
//
//  BaseTools.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/3.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents
//import SDWebImage

func MIN<T : Comparable>(x: T, y: T) -> T{
    if x > y {
        return y
    }
    return x
}

func MAX<T : Comparable>(x: T, y: T) -> T{
    if x < y {
        return y
    }
    return x
}

func jsonToData(jsonDic:NSDictionary) ->Data?{
    
    if(!JSONSerialization.isValidJSONObject(jsonDic)) {
        
        print("is not a valid json object")
        
        return nil
        
    }
    
    //利用自带的json库转换成Data
    
    //如果设置options为JSONSerialization.WritingOptions.prettyPrinted，则打印格式更好阅读
    
    let data = try? JSONSerialization.data(withJSONObject: jsonDic, options: [JSONSerialization.WritingOptions.prettyPrinted])
    
    //Data转换成String打印输出
    
    let str = String(data:data!, encoding: String.Encoding.utf8)
    
    //输出json字符串
    
    print("Json Str:\(str!)")
    
    return data
}

func jsonToData(jsonDictionary:Dictionary<String, Any>) ->Data?{
    
    if(!JSONSerialization.isValidJSONObject(jsonDictionary)) {
        
        print("is not a valid json object")
        
        return nil
        
    }
    
    //利用自带的json库转换成Data
    
    //如果设置options为JSONSerialization.WritingOptions.prettyPrinted，则打印格式更好阅读
    
    let data = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: [JSONSerialization.WritingOptions.prettyPrinted])
    
    //Data转换成String打印输出
    
    let str = String(data:data!, encoding: String.Encoding.utf8)
    
    //输出json字符串
    
    print("Json Str:\(str!)")
    
    return data
}

func dataToNSDictionary(data:Data?) ->NSDictionary?{
    var dic:NSDictionary?
    guard let data = data else {
         return nil
    }
    do {
        if let dict = try JSONSerialization.jsonObject(with:data, options: .mutableContainers) as? NSDictionary{
          dic = dict
        }
    } catch  {
        
    }
    return dic
}

func jsonToString(json: Any, prettyPrinted: Bool = false) -> String {
    var options: JSONSerialization.WritingOptions = []
    if prettyPrinted {
        options = JSONSerialization.WritingOptions.prettyPrinted
    }
    
    do {
        let data = try JSONSerialization.data(withJSONObject: json, options: options)
        if let string = String(data: data, encoding: String.Encoding.utf8) {
            return string
        }
    } catch {
        print(error)
    }
    
    return ""
}

func sizeString(_ size :Int64) ->String{
    var sizeText:String?
    if size == 0{
        return "0B"
    }
    let doubleSize = Double(size)
    if doubleSize >= pow(Double(10) , Double(9)) { // size >= 1GB
        sizeText = "\(String(format: "%.2f", doubleSize/pow(Double(10) , Double(9))))G"
    } else if doubleSize >= pow(Double(10), Double(6)) { // 1GB > size >= 1MB
        sizeText = "\(String(format: "%.2f", doubleSize/pow(Double(10), Double(6))))M"
    } else if doubleSize >= pow(Double(10), Double(3)) { // 1MB > size >= 1KB
        sizeText = "\(String(format: "%.2f", doubleSize/pow(Double(10), Double(3))))K"
    } else { // 1KB > size
        sizeText = "\(String(format: "%lld", size))B"
    }
    return sizeText ?? ""
}



func saveToUserDefault(value:Any,key:String){
    userDefaults.set(value, forKey: key)
    userDefaults.synchronize()
}

func JWTTokenString(token:String) -> String {
    return "JWT \(token)"
}

class Weak<T: AnyObject> {
    weak var value : T?
    init (value: T) {
        self.value = value
    }
}


func mainThreadSafe(_ closure: @escaping ()->()){
//    if let currentQueueLabel = OperationQueue.current?.underlyingQueue?.label {
//        print(currentQueueLabel)
//        if currentQueueLabel == DispatchQueue.main.label {
       if dispatch_is_main_queue(){
            closure()
        }else{
            DispatchQueue.main.async {
                closure()
            }
        }
//    }else{
//        DispatchQueue.main.async {
//            closure()
//        }
//    }
}

func synced(_ lock: Any, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

func  isNilString(_ string:String?) -> Bool{
    if (string == nil || string?.count == 0 || (string?.isEmpty)! || string == "null") {
        return true
    }else{
       return false
    }
}


func changeControllerFromOldController(self:UIViewController, oldController:UIViewController,newController:UIViewController) {
    self.addChildViewController(newController)
    self.transition(from: oldController, to: newController, duration: 0.3, options: UIViewAnimationOptions.curveEaseIn, animations: {
        
    }) { (finish) in
        if(finish){
            newController.didMove(toParentViewController: self)
            oldController.willMove(toParentViewController: nil)
            oldController.removeFromParentViewController()
        }
    }
}

func retrieveTabbarController() -> WSTabBarController?{
    let window = UIApplication.shared.keyWindow
    let tabbarController = window?.rootViewController
    if  tabbarController is WSTabBarController {
        return tabbarController as? WSTabBarController
    }
    return nil
}

 func getUniqueDevice() -> String? {
    var strApplicationUUID = SAMKeychain.password(forService: kKeyChainService, account: kKeyChainAccount)
    if strApplicationUUID == nil {
        strApplicationUUID = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let query = SAMKeychainQuery()
        query.service = kKeyChainService
        query.account = kKeyChainAccount
        query.password = strApplicationUUID
        query.synchronizationMode = SAMKeychainQuerySynchronizationMode.no
        do {
            try query.save()
        }catch{
          print(error)
        }
    }
    return strApplicationUUID
}

func deleteUniqueDevice()->Bool{
    return SAMKeychain.deletePassword(forService: kKeyChainService, account: kKeyChainAccount)
}

//- (void)changeControllerFromOldController:(UIViewController *)oldController toNewController:(UIViewController *)newController
//{
//    [self addChildViewController:newController];
//    /**
//     *  切换ViewController
//     */
//    [self transitionFromViewController:oldController toViewController:newController duration:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
//
//        //做一些动画
//
//        } completion:^(BOOL finished) {
//
//        if (finished) {
//
//        //移除oldController，但在removeFromParentViewController：方法前不会调用willMoveToParentViewController:nil 方法，所以需要显示调用
//        [newController didMoveToParentViewController:self];
//        [oldController willMoveToParentViewController:nil];
//        [oldController removeFromParentViewController];
//        currentVC = newController;
//
//        }else
//        {
//        currentVC = oldController;
//        }
//
//        }];
//}

