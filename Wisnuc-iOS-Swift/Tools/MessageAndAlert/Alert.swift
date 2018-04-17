//
//  Alert.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/17.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MDCAlertController

class Alert: NSObject {
    class func alert(title:String , message:String) {
        let materialAlertController = MDCAlertController.init(title: title, message: message)
        let controller = UIViewController.currentViewController()
        controller.present(materialAlertController, animated: true, completion: nil)
    }
//    NSString *titleString = @"Using Material alert controller?";
//    NSString *messageString = @"Be careful with modal alerts as they can be annoying if over-used.";
//
//    MDCAlertController *materialAlertController =
//    [MDCAlertController alertControllerWithTitle:titleString message:messageString];
//
//    MDCAlertAction *agreeAaction = [MDCAlertAction actionWithTitle:@"AGREE"
//    handler:^(MDCAlertAction *action) {
//    NSLog(@"%@", @"AGREE pressed");
//    }];
//    [materialAlertController addAction:agreeAaction];
//
//    MDCAlertAction *disagreeAaction = [MDCAlertAction actionWithTitle:@"DISAGREE"
//    handler:^(MDCAlertAction *action) {
//    NSLog(@"%@", @"DISAGREE pressed");
//    }];
//    [materialAlertController addAction:disagreeAaction];
    //        [self presentViewController:materialAlertController animated:YES completion:NULL];
    
}
