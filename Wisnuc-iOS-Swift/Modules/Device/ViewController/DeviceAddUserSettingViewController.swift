//
//  DeviceAddUserSettingViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/17.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class DeviceAddUserSettingViewController: BaseViewController {

    let identifier = "celled"
    let headerHeight:CGFloat = 48
    var publicSpace:Int = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        self.largeTitle = LocalizedString(forKey: "添加用户")
        self.view.addSubview(backupTableView)
        self.view.bringSubview(toFront: appBar.appBarViewController.headerView)
        self.view.addSubview(nextButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.trackingScrollView = self.backupTableView
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = true
        ViewTools.automaticallyAdjustsScrollView(scrollView: self.backupTableView, viewController: self)
    }
    
    deinit {
        // Required for pre-iOS 11 devices because we've enabled observesTrackingScrollViewScrollEvents.
        appBar.appBarViewController.headerView.trackingScrollView = nil
    }
    
    @objc func switchBtnHandleForUSB(_ sender:UISwitch){
        
    }
    
    @objc func switchBtnHandleForShare(_ sender:UISwitch){
        if sender.isOn {
            self.publicSpace = 1
        }else{
            self.publicSpace = 0
        }
    }
    
    @objc func nextButtonTap(_ sender:UIButton){
        let aaddUserPhoneNumberViewController = DeviceAaddUserPhoneNumberViewController.init(style: .whiteWithoutShadow,publicSpace:self.publicSpace)
        self.navigationController?.pushViewController(aaddUserPhoneNumberViewController, animated: true)
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
    
    lazy var nextButton: UIButton = {
        let button = UIButton.init(type: .custom)
        let width:CGFloat = 40
        button.frame = CGRect(x: __kWidth - MarginsWidth - width , y: __kHeight - MarginsWidth - width, width: width, height: width)
        button.setImage(UIImage.init(named: "next_button_arrow_white.png"), for: UIControlState.normal)
        button.backgroundColor =  COR1
        button.layer.masksToBounds = true
        button.layer.cornerRadius = width/2
        button.addTarget(self, action: #selector(nextButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        return button
    }()
}

extension DeviceAddUserSettingViewController:UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
             return 3
        }else{
             return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
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
        
        if section == 0{
            leftLabel.text = LocalizedString(forKey: "设置权限")
        }else{
            leftLabel.text = LocalizedString(forKey: "共用空间")
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: identifier)
        if indexPath.section == 0{
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = LocalizedString(forKey: "云盘")
                cell.detailTextLabel?.text = LocalizedString(forKey: "开启")
            case 1:
                cell.textLabel?.text = LocalizedString(forKey: "相册")
                cell.detailTextLabel?.text = LocalizedString(forKey: "开启")
            case 2:
                cell.textLabel?.text = LocalizedString(forKey: "共享空间")
                let switchBtn = UISwitch.init()
                switchBtn.center = CGPoint.init(x: __kWidth - 16 - switchBtn.width/2, y: cell.height/2)
                switchBtn.isOn = self.publicSpace == 0 ? false : true
                switchBtn.addTarget(self, action: #selector(switchBtnHandleForShare(_ :)), for: UIControlEvents.valueChanged)
                cell.contentView.addSubview(switchBtn)
            default:
                break
            }
        }else{
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = LocalizedString(forKey: "共用所有空间")
            default:
                break
            }
        }
        
        cell.separatorInset = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 0)
        cell.textLabel?.textColor = DarkGrayColor
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cell.detailTextLabel?.textColor = LightGrayColor
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
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



