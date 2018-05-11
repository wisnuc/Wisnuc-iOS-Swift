//
//  DrawerViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/10.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class DrawerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addChildViewController(filsDrawerVC)
        self.didMove(toParentViewController: filsDrawerVC)
        filsDrawerVC.view.frame = self.view.frame
        self.view.addSubview(filsDrawerVC.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    lazy var filsDrawerVC: FilesDrawerTableViewController = {
        let vc =  FilesDrawerTableViewController.init(style: UITableViewStyle.grouped)
        return vc
    }()
}
