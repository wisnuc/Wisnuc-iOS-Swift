//
//  SettingRootViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/8/15.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class SettingRootViewController: BaseViewController {
    let identifier = "Cellidentifier"
    let cellHtight:CGFloat = 52
    var autoBackupSwitchOn = false
    var wifiSwitchOn = true
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = LocalizedString(forKey: "Settings")
       
        appBar.headerViewController.headerView.trackingScrollView = settingTabelView
        self.view.addSubview(settingTabelView)
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tab = retrieveTabbarController(){
           if tab.tabBarHidden{
                tab.setTabBarHidden(false, animated: true)
            }
        }
    }
    
    func setSwitchState(){
        autoBackupSwitchOn = AppUserService.currentUser?.autoBackUp?.boolValue ?? false
        wifiSwitchOn = AppUserService.currentUser?.isWIFIAutoBackup?.boolValue ?? true
    }
    
    @objc func switchBtnHandleForSync(_ sender:UISwitch){
        AppUserService.currentUser?.autoBackUp = NSNumber.init(value: sender.isOn)
        AppUserService.synchronizedCurrentUser()
        autoBackupSwitchOn = sender.isOn
        if autoBackupSwitchOn {
//            [SXLoadingView showProgressHUD:@" "];
//            [WB_AppServices startUploadAssets:^{
//                [SXLoadingView hideProgressHUD];
//                }];
        } else{
//            [WB_AppServices.photoUploadManager stop];
        }
    }
    
    @objc func switchBtnHandleForWIFISync(_ sender:UISwitch){
        AppUserService.currentUser?.isWIFIAutoBackup = NSNumber.init(value: sender.isOn)
        AppUserService.synchronizedCurrentUser()
        wifiSwitchOn = sender.isOn
        if wifiSwitchOn {
            //            [SXLoadingView showProgressHUD:@" "];
            //            [WB_AppServices startUploadAssets:^{
            //                [SXLoadingView hideProgressHUD];
            //                }];
        } else{
            //            [WB_AppServices.photoUploadManager stop];
        }
    }
    
    func logoutAction(){
        AppUserService.logoutUser()
        AppService.sharedInstance().abort()
        appDelegate.initRootVC()
    }
    
    lazy var settingTabelView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.tableFooterView = UIView.init()
        return tableView
    }()
}

extension SettingRootViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let transferTaskTableViewController = TransferTaskTableViewController.init(style:NavigationStyle.whiteStyle)
            self.navigationController?.pushViewController(transferTaskTableViewController, animated: true)
            if let tab = retrieveTabbarController(){
                tab.setTabBarHidden(true, animated: true)
            }
        case 1:break
        case 2:break
        case 3:
          self.logoutAction()
        default: break
            
        }
    }
}

extension SettingRootViewController:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHtight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = LocalizedString(forKey: "transfer")
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        case 1:
            cell.textLabel?.text = LocalizedString(forKey: "自动备份照片")
            let switchBtn = UISwitch.init()
            switchBtn.center = CGPoint.init(x: __kWidth - 16 - switchBtn.width/2, y: cell.height/2)
            switchBtn.isOn = autoBackupSwitchOn
            switchBtn.addTarget(self, action: #selector(switchBtnHandleForSync(_ :)), for: UIControlEvents.valueChanged)
            if(!AppUserService.isUserLogin)
            {switchBtn.isEnabled = false}
            cell.contentView.addSubview(switchBtn)
        case 2:
            cell.textLabel?.text = LocalizedString(forKey: "仅WIFI下备份")
            let switchBtn = UISwitch.init()
            switchBtn.center = CGPoint.init(x: __kWidth - 16 - switchBtn.width/2, y: cell.height/2)
            switchBtn.isOn = wifiSwitchOn
            switchBtn.addTarget(self, action: #selector(switchBtnHandleForWIFISync(_ :)), for: UIControlEvents.valueChanged)
            if(!AppUserService.isUserLogin)
            {switchBtn.isEnabled = false}
            cell.contentView.addSubview(switchBtn)
        case 3:
            cell.textLabel?.text = LocalizedString(forKey: "Log out")
        default: break
            
        }
        return cell
    }

}
