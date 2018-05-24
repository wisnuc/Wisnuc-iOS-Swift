
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

func setRootViewController(){
    let tabBarController = WSTabBarController ()
    
    let filesVC = FilesRootViewController()
    filesVC.selfState = .root
    filesVC.title = LocalizedString(forKey: "Files")
    let photosVC = BaseViewController()
    photosVC.title = "Downloads"
    photosVC.view.backgroundColor = UIColor.blue
    let shareVC = BaseViewController()
    shareVC.title = "History"
    shareVC.view.backgroundColor = UIColor.cyan
    
    
    let filesNavi = BaseNavigationController.init(rootViewController: filesVC)
    let photosNavi = BaseNavigationController.init(rootViewController: photosVC)
    let shareNavi = BaseNavigationController.init(rootViewController: shareVC)
    filesNavi.tabBarItem = UITabBarItem(title:  LocalizedString(forKey: "files"), image: UIImage.init(named: "warning.png")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: UIImage.init(named: "tab_files.png")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal))
    photosNavi.tabBarItem = UITabBarItem(title:  LocalizedString(forKey: "files"), image: UIImage.init(named: "Home"), selectedImage: UIImage.init(named: "tab_files.png"))
    shareNavi.tabBarItem = UITabBarItem(title:  LocalizedString(forKey: "files"), image: UIImage.init(named: "Home"), selectedImage: UIImage.init(named: "tab_files.png"))
  
    let controllers = [filesNavi, photosNavi, shareNavi]
    tabBarController.viewControllers = controllers
    tabBarController.tabBar?.items = [filesNavi.tabBarItem,
                     photosNavi.tabBarItem ,
                     shareNavi.tabBarItem]
    tabBarController.tabBar?.setImageTintColor(COR1, for: MDCTabBarItemState.normal)
    tabBarController.tabBar?.setImageTintColor(LightGrayColor, for: MDCTabBarItemState.selected)
    tabBarController.tabBar?.selectedItem = tabBarController.tabBar?.items[0]
    tabBarController.selectedViewController = controllers[0]
    tabBarController.tabBar?.itemAppearance = MDCTabBarItemAppearance.titledImages
    MDCTabBarColorThemer.apply(appDlegate.colorScheme, to: tabBarController.tabBar!)

    tabBarController.tabBar?.backgroundColor = UIColor.white
    tabBarController.tabBar?.selectedItemTintColor = COR1
    tabBarController.tabBar?.unselectedItemTintColor = LightGrayColor
    let window = UIApplication.shared.keyWindow
    let drawerVC = DrawerViewController.init()
    let naviNavigationDrawer = AppNavigationDrawerController(rootViewController: tabBarController, leftViewController: drawerVC, rightViewController: nil)
    window?.rootViewController = naviNavigationDrawer
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

