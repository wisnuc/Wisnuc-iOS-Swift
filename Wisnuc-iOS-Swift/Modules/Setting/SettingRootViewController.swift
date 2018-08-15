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
    var switchOn = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = LocalizedString(forKey: "Setting")
        switchOn = AppUserService.currentUser?.autoBackUp?.boolValue ?? false
        appBar.headerViewController.headerView.trackingScrollView = settingTabelView
        self.view.addSubview(settingTabelView)
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func switchBtnHandleForSync(_ sender:UISwitch){
        AppUserService.currentUser?.autoBackUp = NSNumber.init(value: sender.isOn)
        AppUserService.synchronizedCurrentUser()
        switchOn = sender.isOn
        if switchOn {
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
        case 0:break
        case 1:
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHtight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = LocalizedString(forKey: "自动备份照片")
            let switchBtn = UISwitch.init()
            switchBtn.center = CGPoint.init(x: __kWidth - 16 - switchBtn.width/2, y: cell.center.y)
            switchBtn.isOn = switchOn
            switchBtn.addTarget(self, action: #selector(switchBtnHandleForSync(_ :)), for: UIControlEvents.valueChanged)
            //        if(!AppUserService.isUserLogin) switchBtn.enabled = NO;
            cell.contentView.addSubview(switchBtn)
        case 1:
             cell.textLabel?.text = LocalizedString(forKey: "Log out")
            
        default: break
            
        }
        return cell
    }

}
