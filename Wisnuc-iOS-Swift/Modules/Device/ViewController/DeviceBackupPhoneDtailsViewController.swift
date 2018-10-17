//
//  DeviceBackupPhoneDtailsViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/16.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class DeviceBackupPhoneDtailsViewController: BaseViewController {
    let identifier = "celled"
    let headerHeight:CGFloat = 8
    var autoBackupSwitchOn = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(backupTableView)
        self.view.bringSubview(toFront: appBar.appBarViewController.headerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.trackingScrollView = self.backupTableView
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = true
        ViewTools.automaticallyAdjustsScrollView(scrollView: self.backupTableView, viewController: self)
    }
    
    @objc func switchBtnHandleForSync(_ sender:UISwitch){
        AppUserService.currentUser?.autoBackUp = NSNumber.init(value: sender.isOn)
        AppUserService.synchronizedCurrentUser()
        autoBackupSwitchOn = sender.isOn
        if autoBackupSwitchOn {
            AppService.sharedInstance().startAutoBackup {
            }
        } else{
            AppService.sharedInstance().autoBackupManager.stop()
        }
    }
    
    lazy var backupTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight), style: UITableViewStyle.plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = lightGrayBackgroudColor
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.sectionFooterHeight = 0.01
        return tableView
    }()
}

extension DeviceBackupPhoneDtailsViewController:UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else{
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return headerHeight
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.zero)
    
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: identifier)
        if indexPath.section == 0{
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = LocalizedString(forKey: "备份")
                
                let switchBtn = UISwitch.init()
                switchBtn.center = CGPoint.init(x: __kWidth - 16 - switchBtn.width/2, y: cell.height/2)
                switchBtn.isOn = autoBackupSwitchOn
                switchBtn.addTarget(self, action: #selector(switchBtnHandleForSync(_ :)), for: UIControlEvents.valueChanged)
                if(!AppUserService.isUserLogin){
                    switchBtn.isEnabled = false
                }
                cell.contentView.addSubview(switchBtn)
                cell.textLabel?.textColor = DarkGrayColor
            default:
                break
            }
        }else{
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = LocalizedString(forKey: "最后一次备份时间")
                cell.detailTextLabel?.text = "2018-09-30 18:55:12"
            case 1:
                cell.textLabel?.text = LocalizedString(forKey: "是否备份完成")
                cell.detailTextLabel?.text = "300/2254"
            case 2:
                cell.textLabel?.text = LocalizedString(forKey: "在相簿中打开")
            default:
                break
            }
            
            cell.textLabel?.textColor = DarkGrayColor
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0{
            switch indexPath.row {
            case 0:
             break
            default:
             break
            }
        }else{
          
        }
    }
}


