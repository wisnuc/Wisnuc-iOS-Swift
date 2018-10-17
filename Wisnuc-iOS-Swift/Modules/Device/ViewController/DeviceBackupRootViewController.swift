//
//  DeviceBackupRootViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/16.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class DeviceBackupRootViewController: BaseViewController {
    let identifier = "celled"
    let headerHeight:CGFloat = 48
    override func viewDidLoad() {
        super.viewDidLoad()
        self.largeTitle = LocalizedString(forKey: "备份空间")
        self.view.addSubview(backupTableView)
        self.view.bringSubview(toFront: appBar.appBarViewController.headerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.trackingScrollView = self.backupTableView
//        appBar.appBarViewController.inferTopSafeAreaInsetFromViewController = true
//        appBar.appBarViewController.headerView.minMaxHeightIncludesSafeArea = false
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = true
//        appBar.headerViewController.headerView.changeContentInsets { [weak self] in
//            self?.appBar.headerViewController.headerView.trackingScrollView?.contentInset = UIEdgeInsets(top: (self?.appBar.headerViewController.headerView.trackingScrollView?.contentInset.top)! + kScrollViewTopMargin, left: 0, bottom: 0, right: 0)
//        }
        
        ViewTools.automaticallyAdjustsScrollView(scrollView: self.backupTableView, viewController: self)
    }
    
    lazy var backupTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight), style: UITableViewStyle.grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = lightGrayBackgroudColor
        tableView.register(UINib.init(nibName: StringExtension.classNameAsString(targetClass: DeviceBackupRootTableViewCell.self), bundle: nil), forCellReuseIdentifier: identifier)
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.sectionFooterHeight = 0.01
        return tableView
    }()
}

extension DeviceBackupRootViewController:UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      
      return headerHeight
       
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.zero)
        let headerBackgroudView = UIView.init(frame: CGRect(x: 0, y: 8, width: __kWidth, height: headerHeight - 8))
        headerBackgroudView.backgroundColor = .white
        headerView.addSubview(headerBackgroudView)
        
        let leftLabel = UILabel.init(frame: CGRect(x: MarginsWidth, y: headerBackgroudView.height/2 - 14/2, width: __kWidth/2 - MarginsWidth, height: 14))
        leftLabel.textColor = LightGrayColor
        leftLabel.font = UIFont.systemFont(ofSize: 14)
        headerBackgroudView.addSubview(leftLabel)
        
        let rightLabel = UILabel.init(frame: CGRect(x: __kWidth - MarginsWidth - (__kWidth/2 - MarginsWidth), y: headerBackgroudView.height/2 - 14/2, width: __kWidth/2 - MarginsWidth, height: 14))
        rightLabel.textColor = LightGrayColor
        rightLabel.font = UIFont.systemFont(ofSize: 14)
        rightLabel.textAlignment = .right
        rightLabel.text = LocalizedString(forKey: "已备容量")
        headerBackgroudView.addSubview(rightLabel)
        
        if section == 0{
            leftLabel.text = LocalizedString(forKey: "来自手机的备份")
        }else{
            leftLabel.text = LocalizedString(forKey: "来自PC的备份")
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DeviceBackupRootTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DeviceBackupRootTableViewCell
        if indexPath.section == 0{
            cell.leftImageView.image = UIImage.init(named: "phone_icon_device.png")
            switch indexPath.row {
            case 0:
                cell.accessoryType = .disclosureIndicator
                cell.titleLabel.text = "iphone X"
                cell.detailLabel.text = "当前手机"
                cell.rightLabel.text = "1.3G"
            case 1:
                cell.accessoryType = .disclosureIndicator
                cell.titleLabel.text = "iphone Xs"
                cell.rightLabel.text = "3G"
            default:
                break
            }
        }else{
            cell.leftImageView.image = UIImage.init(named: "pc_icon_device.png")
            switch indexPath.row {
            case 0:
                cell.accessoryType = .disclosureIndicator
                cell.titleLabel.text = "MAC"
                cell.rightLabel.text = "1.3G"
            case 1:
                cell.accessoryType = .disclosureIndicator
                cell.titleLabel.text = "PC"
                cell.rightLabel.text = "3G"
            default:
                break
            }
        }
 
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0{
            switch indexPath.row {
            case 0:
                let deviceBackupPhoneDtailsViewController = DeviceBackupPhoneDtailsViewController.init(style:.highHeight)
                let tab = retrieveTabbarController()
                deviceBackupPhoneDtailsViewController.largeTitle = "iphone X"
                tab?.setTabBarHidden(true, animated: true)
                self.navigationController?.pushViewController(deviceBackupPhoneDtailsViewController, animated: true)
            default:
                let deviceBackupPhoneDtailsViewController = DeviceBackupPhoneDtailsViewController.init(style:.highHeight)
                let tab = retrieveTabbarController()
                deviceBackupPhoneDtailsViewController.largeTitle = "iphone XR"
                tab?.setTabBarHidden(true, animated: true)
                self.navigationController?.pushViewController(deviceBackupPhoneDtailsViewController, animated: true)
            }
        }else{
            let deviceBackupPCDtailsViewController = DeviceBackupPhoneDtailsViewController.init(style:.highHeight)
            deviceBackupPCDtailsViewController.largeTitle = "MAC"
            let tab = retrieveTabbarController()
            tab?.setTabBarHidden(true, animated: true)
            self.navigationController?.pushViewController(deviceBackupPCDtailsViewController, animated: true)
        }
    }
}


