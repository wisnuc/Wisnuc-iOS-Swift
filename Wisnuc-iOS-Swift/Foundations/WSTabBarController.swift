//
//  WSTabBarController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/3.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents
private let FilesNormalImage = UIImage.init(named: "tab_files")
private let PhotoNormalImage = UIImage.init(named: "tab_photos.png")
private let DeviceNormalImage = UIImage.init(named: "tab_device.png")
private let MyNormalImage = UIImage.init(named: "tab_my.png")

private let FilesSelectImage = UIImage.init(named: "tab_files_selected.png")
private let PhotoSelectImage = UIImage.init(named: "tab_photos_selected.png")
private let DeviceSelectImage = UIImage.init(named: "tab_device_selected.png")
private let MySelectImage = UIImage.init(named: "tab_my_selected.png")

class WSTabBarController: MDCTabBarViewController  {
    let bottomNavBar = MDCBottomNavigationBar()
    init() {
        super.init(nibName: nil, bundle: nil)
        self.delegate = self
        self.view.backgroundColor = UIColor.white
    }
    
    override var childViewControllerForStatusBarStyle: UIViewController?{
         return selectedViewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    #if swift(>=3.2)
    @available(iOS 11, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

    }
    #endif
    
    func loadTabbar(){

    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.hidesBottomBarWhenPushed = true
//        self.tabBar?.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension WSTabBarController:MDCTabBarControllerDelegate{
    func tabBarController(_ tabBarController: MDCTabBarViewController, didSelect viewController: UIViewController) {
        let item =  viewController.tabBarItem!
        guard let index = tabBarController.tabBar?.items.index(of:item) else {
            fatalError("MDCTabBarDelegate given selected item not found in tabBar.items")
        }
//        item.setBadgeTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.black], for: UIControlState.selected)
        print(index)
        switch index {
        case 0:
            item.image = FilesSelectImage
        case 1:
            item.image = PhotoSelectImage
        case 2:
            item.image = DeviceSelectImage
           
        case 3:
            item.image = MySelectImage
        default:
            break
        }
        
        for (idx,value) in (tabBarController.tabBar?.items.enumerated())!{
            if idx != index{
                switch value.tag {
                case 0:
                    value.image = FilesNormalImage
                case 1:
                    value.image = PhotoNormalImage
                case 2:
                    value.image = DeviceNormalImage
                case 3:
                    value.image = MyNormalImage
                default:
                    break
                }
            }
        }
    }
}

