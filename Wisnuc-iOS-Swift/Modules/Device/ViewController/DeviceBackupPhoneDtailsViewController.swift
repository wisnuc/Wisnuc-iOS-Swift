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
    var isCurrent:Bool?
    var model:DriveModel?
    init(style: NavigationStyle,model:DriveModel,isCurrent:Bool) {
        super.init(style: style)
        self.model = model
        self.isCurrent = isCurrent
        self.largeTitle = model.label
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(backupTableView)
        self.view.bringSubview(toFront: appBar.appBarViewController.headerView)
    }
    
    func setBackupSetting(cell:UITableViewCell,indexPath:IndexPath){
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = LocalizedString(forKey: "最后一次备份时间")
            let lastBackupTime = self.model?.client?.lastBackupTime != nil ? TimeTools.timeString(TimeInterval((self.model?.client?.lastBackupTime)!/1000)) : LocalizedString(forKey: "暂无备份")
            cell.detailTextLabel?.text = lastBackupTime
        case 1:
            cell.textLabel?.text = LocalizedString(forKey: "是否备份完成")
            if isCurrent!{
                if self.model?.client?.status == DriveClientModelState.Working.rawValue{
                    cell.detailTextLabel?.text = LocalizedString(forKey: "正在备份")
                }else if self.model?.client?.status == DriveClientModelState.Idle.rawValue{
                    cell.detailTextLabel?.text = LocalizedString(forKey: "完成")
                }else{
                    
                }
            }else{
                switch BackupPlatformType(rawValue: model?.client?.type ?? "") {
                case .WinPC?,.LinuxPC?,.MacPC?:
                    cell.textLabel?.text =  LocalizedString(forKey: "在云盘中打开")
                case .AndroidMobile?,.iOSMobile?:
                    cell.textLabel?.text =  LocalizedString(forKey: "在相簿中打开")
                default:
                    break
                }
                 cell.accessoryType = .disclosureIndicator
            }
        case 2:
            switch BackupPlatformType(rawValue: model?.client?.type ?? "") {
            case .WinPC?,.LinuxPC?,.MacPC?:
                cell.textLabel?.text =  LocalizedString(forKey: "在云盘中打开")
            case .AndroidMobile?,.iOSMobile?:
                cell.textLabel?.text =  LocalizedString(forKey: "在相簿中打开")
            default:
                break
            }
             cell.accessoryType = .disclosureIndicator
        default:
            break
        }
    }
    
    func openInPhotos(){
        guard let model = self.model else {
            return
        }
        guard let placesUUID = model.uuid else {
            return
        }
        let photosVC = PhotoRootViewController.init(style: NavigationStyle.whiteWithoutShadow,state:.normal,driveUUID:placesUUID)
        photosVC.title = model.label
        DispatchQueue.global(qos: .default).async {
            
            let requset = GetMediaAPI.init(classType: RequestMediaClassValue.Image, placesUUID: placesUUID)
            requset.startRequestJSONCompletionHandler({ (response) in
                if let error = response.error{
                   Message.message(text:  error.localizedDescription)
                }else{
                    if let errorMessage = ErrorTools.responseErrorData(response.data) {
                        Message.message(text:  errorMessage)
                        return
                    }
                    let isLocalRequest = AppNetworkService.networkState == .local
                    let medias:NSArray = (isLocalRequest ? response.value as? NSArray : (response.value as! NSDictionary)["data"]) as! NSArray
                    DispatchQueue.global(qos: .default).async {
                        var array = Array<NetAsset>.init()
                        medias.enumerateObjects({ (object, idx, stop) in
                            if object is NSDictionary{
                                if let model = NetAsset.deserialize(from: object as? NSDictionary) {
                                    array.append(model)
                                }
                            }
                        })
                        DispatchQueue.main.async {
                            photosVC.addNetAssets(assetsArr: array)
                        }
                    }
                }
            })
            photosVC.requset = requset
        }
        self.navigationController?.pushViewController(photosVC, animated: true)
    }
    
    func openInFiles(){
        guard let model = self.model else {
            return
        }
        guard let uuid = model.uuid else {
            return
        }
        let nextViewController = FilesRootViewController.init(driveUUID: uuid, directoryUUID: uuid,style:.white)
        nextViewController.title = LocalizedString(forKey: model.label ?? "")
        self.navigationController?.pushViewController(nextViewController, animated: true)
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
            guard let uuid = self.model?.uuid else{
                return
            }
            AppService.sharedInstance().startAutoBackup(uuid: uuid) {
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
        if isCurrent!{
           return 2
        }
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isCurrent!{
            if section == 0{
                return 1
            }else{
                return 3
            }
        }else{
            return 2
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
            if isCurrent!{
                switch indexPath.row {
                case 0:
                    cell.selectionStyle = .none
                    cell.textLabel?.text = LocalizedString(forKey: "照片备份")
                    cell.contentView.removeAllSubviews()
                    let switchBtn = UISwitch.init()
                    switchBtn.center = CGPoint.init(x: __kWidth - 16 - switchBtn.width/2, y: 56/2)
                    switchBtn.isOn = autoBackupSwitchOn
                    switchBtn.addTarget(self, action: #selector(switchBtnHandleForSync(_ :)), for: UIControlEvents.valueChanged)
                    if(!AppUserService.isUserLogin){
                        switchBtn.isEnabled = false
                    }
                    cell.contentView.addSubview(switchBtn)
                default:
                    break
                }
            }else{
              self.setBackupSetting(cell: cell, indexPath: indexPath)
            }
        }else{
            self.setBackupSetting(cell: cell, indexPath: indexPath)
        }
        cell.textLabel?.textColor = DarkGrayColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isCurrent!{
            if indexPath.section != 0{
                if indexPath.row == 2{
                    openInPhotos()
                }
            }
        }else{
            if indexPath.row == 1{
                openInFiles()
            }
        }
    }
}


