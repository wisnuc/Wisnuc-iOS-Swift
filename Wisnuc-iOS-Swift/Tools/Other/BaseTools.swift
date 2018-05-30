
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

func mainThreadSave(){
  
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

