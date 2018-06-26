
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
import SDWebImage

func jsonToData(jsonDic:NSDictionary) ->Data?{
    
    if(!JSONSerialization.isValidJSONObject(jsonDic)) {
        
        print("is not a valid json object")
        
        return nil
        
    }
    
    //利用自带的json库转换成Data
    
    //如果设置options为JSONSerialization.WritingOptions.prettyPrinted，则打印格式更好阅读
    
    let data = try? JSONSerialization.data(withJSONObject: jsonDic, options: [])
    
    //Data转换成String打印输出
    
    let str = String(data:data!, encoding: String.Encoding.utf8)
    
    //输出json字符串
    
    print("Json Str:\(str!)")
    
    return data
    
}

func sizeString(_ size :Int64) ->String{
    var sizeText:String?
    if size == 0{
        return ""
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

func timeString(_ timeSecond:TimeInterval) ->String{
    let date = Date.init(timeIntervalSince1970: timeSecond)
    let formater = DateFormatter.init()
    formater.dateFormat = "yyyy年MM月dd日"
//    "yyyy年MM月dd日 hh:mm:ss"
    let dateString = formater.string(from: date)
    return dateString
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
    if let currentQueueLabel = OperationQueue.current?.underlyingQueue?.label {
        print(currentQueueLabel)
        if currentQueueLabel == DispatchQueue.main.label {
            closure()
        }else{
            DispatchQueue.main.async {
                closure()
            }
        }
    }else{
        DispatchQueue.main.async {
            closure()
        }
    }
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

