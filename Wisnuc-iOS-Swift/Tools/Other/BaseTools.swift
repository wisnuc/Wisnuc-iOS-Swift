
//
//  BaseTools.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/3.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation
import UIKit

let appDlegate = UIApplication.shared.delegate as! AppDelegate

func setRootViewController(){
    let tabBarController = WSTabBarController()
    
    let favoritesVC = ViewController()
    
    favoritesVC.title = "Favorites"
    favoritesVC.view.backgroundColor = UIColor.orange
    let downloadsVC = ViewController()
    downloadsVC.title = "Downloads"
    downloadsVC.view.backgroundColor = UIColor.blue
    let historyVC = ViewController()
    historyVC.title = "History"
    historyVC.view.backgroundColor = UIColor.cyan
    
    favoritesVC.tabBarItem = UITabBarItem(title: "one", image: UIImage.init(named: "Home"), tag: 0)
    downloadsVC.tabBarItem = UITabBarItem(title: "two", image: UIImage.init(named: "Home"), tag: 1)
    historyVC.tabBarItem = UITabBarItem(title: "three", image: UIImage.init(named: "Home"), tag: 2)
    
    let controllers = [favoritesVC, downloadsVC, historyVC]
    tabBarController.viewControllers = controllers
    tabBarController.selectedViewController = controllers[0]

    let window = UIApplication.shared.keyWindow
    window?.rootViewController = tabBarController
}
