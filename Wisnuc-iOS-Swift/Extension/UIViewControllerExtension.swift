//
//  UIViewControllerExtension.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/17.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents

@objc protocol BackButtonHandlerProtocol:NSObjectProtocol{
    @objc optional func navigationShouldPopOnBackButton() -> Bool
}

extension UIViewController: BackButtonHandlerProtocol{
    
    func alertController(title: String? = nil, message: String? = nil,cancelActionTitle:String? = nil,okActionTitle:String? = nil,okActionHandler:((UIAlertAction) -> Void)? = nil,cancelActionHandler:((UIAlertAction) -> Void)? = nil){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        if cancelActionTitle != nil{
            let cancelAction = UIAlertAction(title: cancelActionTitle, style: UIAlertActionStyle.cancel, handler: cancelActionHandler)
            cancelAction.setValue(COR1, forKey: "titleTextColor")
            alertController.addAction(cancelAction)
        }
        
        if okActionTitle != nil{
            let okAction = UIAlertAction (title: okActionTitle!, style: UIAlertActionStyle.default, handler: okActionHandler)
//            if okAction.value(forKey: "titleTextColor") != nil {
                okAction.setValue(COR1, forKey: "titleTextColor")
//            }
            alertController.addAction(okAction)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    class func currentViewController() -> UIViewController? {
        let window = UIApplication.shared.keyWindow
        var controller = window?.rootViewController
        while true {
            if((controller?.presentedViewController) != nil){
                controller = controller?.presentedViewController
            }else{
                if controller == nil{
                return nil
                }
                if (controller?.isKind(of: UINavigationController.self))!{
                    controller = controller?.childViewControllers.last
                }else if (controller?.isKind(of: UITabBarController.self))!{
                    let tabBarController = controller as! UITabBarController
                    controller = tabBarController.selectedViewController
                }else{
                    if (controller?.childViewControllers.count)!>0{
                        if (controller?.childViewControllers.last?.isKind(of: MDCAppBarViewController.self))!{
                             return controller!
                        }
                        controller = controller?.childViewControllers.last
                    }else{
//
//                            controller = controller?.childViewControllers.last
//                        }else{
                            return controller!
//                        }
                    }
                }
            }
        }
    }
    
    func navigationShouldPopOnBackButton() -> Bool {
        return true
    }
    
    func xx_navigationBarTopLayoutGuide() ->  UILayoutSupport{
        if (self.parent != nil) && !(self.parent?.isKind(of: UINavigationController.self))! {
            return (self.parent?.xx_navigationBarTopLayoutGuide())!
        }else{
            return self.topLayoutGuide
        }
    }
    
    func xx_navigationBarBottomLayoutGuide() ->  UILayoutSupport{
        if (self.parent != nil) && !(self.parent?.isKind(of: UINavigationController.self))! {
            return (self.parent?.xx_navigationBarBottomLayoutGuide())!
        }else{
            return self.bottomLayoutGuide
        }
    }
    
    func xx_fixNavBarPenetrable (){
        if self.childViewControllers.count == 0 {
            return
        }
        
        var statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        if self.navigationController != nil {
            statusBarHeight = 0.0
        }
        for (_,value) in self.childViewControllers.enumerated() {
            for (_,obj) in value.view.subviews.enumerated() {
                if obj.isKind(of: UIScrollView.self) {
                    let tv:UIScrollView = obj as! UIScrollView
                    let insets = (value.automaticallyAdjustsScrollViewInsets) ?  UIEdgeInsetsMake(value.xx_navigationBarTopLayoutGuide().length - statusBarHeight, 0.0, value.xx_navigationBarBottomLayoutGuide().length, 0.0) : UIEdgeInsets.zero
                    tv.scrollIndicatorInsets = insets
                    tv.contentInset = tv.scrollIndicatorInsets
                    tv.contentOffset  = CGPoint(x: insets.left, y: -insets.top)
                    break
                }
            }
        }

        
//    - (void)xx_fixNavBarPenetrable {
//
//    if(!self.childViewControllers.count) return;
//    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
//    if (self.navigationController) {statusBarHeight = 0.0f;}
//    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//    [obj.view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull v_obj, NSUInteger v_idx, BOOL * _Nonnull v_stop) {
//    if ([v_obj isKindOfClass:[UIScrollView class]]) {
//    UIScrollView *tv = (UIScrollView *)v_obj;
//    const UIEdgeInsets insets = (obj.automaticallyAdjustsScrollViewInsets) ? UIEdgeInsetsMake(obj.xx_navigationBarTopLayoutGuide.length - statusBarHeight, 0.0f, obj.xx_navigationBarBottomLayoutGuide.length, 0.0f) : UIEdgeInsetsZero;
//    tv.contentInset = tv.scrollIndicatorInsets = insets;
//    tv.contentOffset = CGPointMake(insets.left, -insets.top);
//    *v_stop = YES;
//    }
//    }];
//    }];
//
//    }
    
//    - (id<UILayoutSupport>)xx_navigationBarTopLayoutGuide {
//    if (self.parentViewController &&
//    ![self.parentViewController isKindOfClass:UINavigationController.class]) {
//    return self.parentViewController.xx_navigationBarTopLayoutGuide;
//    } else {
//    return self.topLayoutGuide;
//    }
//    }
//    - (id<UILayoutSupport>)xx_navigationBarBottomLayoutGuide {
//    if (self.parentViewController &&
//    ![self.parentViewController isKindOfClass:UINavigationController.class]) {
//    return self.parentViewController.xx_navigationBarBottomLayoutGuide;
//    } else {
//    return self.bottomLayoutGuide;
//    }
   }
}


