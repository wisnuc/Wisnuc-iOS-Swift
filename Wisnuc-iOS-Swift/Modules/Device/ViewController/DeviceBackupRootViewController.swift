//
//  DeviceBackupRootViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/16.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
enum DeviceBackupRootViewControllerNextType {
    case files
    case device
}

class DeviceBackupRootViewController: BaseViewController {
    let identifier = "celled"
    let headerHeight:CGFloat = 48
    var type:DeviceBackupRootViewControllerNextType?
    init(style: NavigationStyle,type:DeviceBackupRootViewControllerNextType) {
        super.init(style: style)
        self.type = type
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        if self.type == .files {
            self.largeTitle = LocalizedString(forKey: "备份空间")
        }else{
            self.largeTitle = LocalizedString(forKey: "备份设置")
        }
        self.view.addSubview(backupTableView)
        self.view.bringSubview(toFront: appBar.appBarViewController.headerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.trackingScrollView = self.backupTableView
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = true
        ViewTools.automaticallyAdjustsScrollView(scrollView: self.backupTableView, viewController: self)
        let tab = retrieveTabbarController()
        tab?.setTabBarHidden(true, animated: true)
        //        appBar.appBarViewController.inferTopSafeAreaInsetFromViewController = true
        //        appBar.appBarViewController.headerView.minMaxHeightIncludesSafeArea = false
        //        appBar.headerViewController.headerView.changeContentInsets { [weak self] in
        //            self?.appBar.headerViewController.headerView.trackingScrollView?.contentInset = UIEdgeInsets(top: (self?.appBar.headerViewController.headerView.trackingScrollView?.contentInset.top)! + kScrollViewTopMargin, left: 0, bottom: 0, right: 0)
        //        }
    }
    
    func loadData(){
        ActivityIndicator.startActivityIndicatorAnimation()
        AppNetworkService.getUserAllBackupDrive { [weak self](error, models) in
            ActivityIndicator.stopActivityIndicatorAnimation()
            if let error = error{
                Message.message(text: error.localizedDescription)
            }else{
                if let models = models{
                    if  models.count>0{
                        self?.dataSource.removeAll()
                        var pcArray = [DriveModel]()
                        var mobileArray = [DriveModel]()
                        for model in models{
                            switch BackupPlatformType(rawValue: model.client?.type ?? "") {
                            case .WinPC?,.MacPC?,.LinuxPC?:
                                pcArray.append(model)
                            case .AndroidMobile?,.iOSMobile?:
                                mobileArray.append(model)
                            default:
                                break
                            }
                        }
                        
                        if pcArray.count > 0{
                            self?.dataSource.append(pcArray)
                            self?.capacity(array: pcArray)
                        }
                        if mobileArray.count > 0{
                            self?.dataSource.append(mobileArray)
                            self?.capacity(array: mobileArray)
                        }
                        self?.backupTableView.reloadData()
                    }else{
                        self?.creatBackupDrive()
                    }
                }else{
                    self?.creatBackupDrive()
                }
            }
        }
    }
    
    func creatBackupDrive(){
        AppNetworkService.creactBackupDrive(callBack: { [weak self](error, driveModel) in
            if let error = error{
                Message.message(text: error.localizedDescription)
            }else{
                if driveModel != nil{
                    self?.loadData()
                }
            }
        })
    }
    
    func capacity(array:[DriveModel]){
        var index:Int = 0
        for model in array{
            self.getCapacity(model: model) {
                index = index + 1
                if index == array.count{
                    self.backupTableView.reloadData()
                }
            }
        }
    }
    
    func getCapacity(model:DriveModel,closure:@escaping ()->()){
        guard let uuid = model.uuid else {
            return closure()
        }
        let request = DriveDirStatsAPI.init(drive: uuid, dir: uuid)
        request.startRequestJSONCompletionHandler { [weak self](response) in
            if let error = response.error{
                Message.message(text: error.localizedDescription)
                return closure()
            }else{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                    return closure()
                }else{
                    guard let rootDic = response.value as? NSDictionary else {
                        return closure()
                    }
                    var dataDic = rootDic
                    let isLocal = AppNetworkService.networkState == .local
                    if !isLocal{
                        if let modelDic = rootDic["data"] as? NSDictionary{
                            dataDic = modelDic
                        }
                    }
                    
                    if let data = jsonToData(jsonDic: dataDic){
                        do{
                            let model = try JSONDecoder().decode(FilesStatsModel.self, from: data)
                            if self?.dataSource.count == 1{
                                if var driveModel = self?.dataSource.first?.first(where: {$0.uuid == uuid}){
                                    driveModel.fileTotalSize = model.fileTotalSize
                                    if let index = self?.dataSource.first?.firstIndex(where: {$0.uuid == uuid}){
                                        self?.dataSource[0][index] = driveModel
                                        return closure()
                                    }
                                }
                            }else if self?.dataSource.count == 2{
                                if var driveModel = self?.dataSource.first?.first(where: {$0.uuid == uuid}){
                                    driveModel.fileTotalSize = model.fileTotalSize
                                    if let index = self?.dataSource.first?.firstIndex(where: {$0.uuid == uuid}){
                                        self?.dataSource[0][index] = driveModel
                                    }
                                }
                                
                                if var driveModel = self?.dataSource.last?.first(where: {$0.uuid == uuid}){
                                    driveModel.fileTotalSize = model.fileTotalSize
                                    if let index = self?.dataSource.last?.firstIndex(where: {$0.uuid == uuid}){
                                        self?.dataSource[1][index] = driveModel
                                    }
                                }
                                
                                return closure()
                            }
        
                        }catch{
                            Message.message(text: error.localizedDescription)
                            return closure()
                        }
                    }
                }
            }
        }
    }
    
    lazy var dataSource: [[DriveModel]] = [[DriveModel]]()
    
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
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
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
        
        let array = dataSource[section]
        if array.first?.client?.type?.contains("PC") ?? false{
            leftLabel.text = LocalizedString(forKey: "来自PC的备份")
        }else{
            leftLabel.text = LocalizedString(forKey: "来自手机的备份")
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DeviceBackupRootTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DeviceBackupRootTableViewCell
        let model = dataSource[indexPath.section][indexPath.row]
        switch BackupPlatformType(rawValue: model.client?.type ?? "") {
        case .WinPC?,.LinuxPC?:
             cell.leftImageView.image = UIImage.init(named: "desktop_icon_backup.png")
        case .MacPC?:
            cell.leftImageView.image = UIImage.init(named: "imac_icon_backup.png")
        case .AndroidMobile?:
            cell.leftImageView.image = UIImage.init(named: "andr_icon_backup.png")
        case .iOSMobile?:
            cell.leftImageView.image = UIImage.init(named: "iphone_icon_backup.png")
        default:
            cell.leftImageView.image = UIImage.init(named: "phone_icon_device.png")
        }
        
        cell.titleLabel.text = model.label
        if let size = model.fileTotalSize{
          cell.rightLabel.text = sizeString(size)
        }
        if getUniqueDevice() == model.client?.id{
            cell.detailLabel.text = "当前手机"
        }else{
            cell.detailLabel.text = nil
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.default, title:
           LocalizedString(forKey: "删除")) { [weak self](tableViewForAction, indexForAction) in
            let index = indexForAction.row
            let model = self?.dataSource[indexPath.section][indexPath.row]
            guard let drive = model?.uuid else {
                return
            }
            DriveOptionAPI.init(drive:drive,type: .delete).startRequestJSONCompletionHandler { [weak self](response) in
                if response.error == nil{
                    if let errorMessage = ErrorTools.responseErrorData(response.data){
                       Message.message(text: errorMessage)
                       return
                    }
                    AppUserService.backupArray.removeAll(where: { (driveModel) -> Bool in
                        return driveModel.uuid == drive
                    })
                    self?.dataSource[indexPath.section].remove(at: index)
                    tableView.deleteRows(at: [IndexPath(row: index, section: indexPath.section)], with: .automatic)
                }else{
                    if let error = response.error{
                        Message.message(text: error.localizedDescription)
                    }
                }
            }
           
        }
        deleteRowAction.backgroundColor = UIColor.red
        return [deleteRowAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.section][indexPath.row]
        if self.type == .files{
            if let uuid = model.uuid {
                let nextViewController = FilesRootViewController.init(driveUUID: uuid, directoryUUID: uuid,style:.white)
                nextViewController.title = LocalizedString(forKey: model.label ?? "")
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
        }else{
            switch BackupPlatformType(rawValue: model.client?.type ?? "") {
            case .WinPC?,.LinuxPC?,.MacPC?: break
                
            case .iOSMobile?,.AndroidMobile?:
            let isCurrent = getUniqueDevice() == model.client?.id ? true : true
            let deviceBackupPhoneDtailsViewController = DeviceBackupPhoneDtailsViewController.init(style:.highHeight,model:model,isCurrent:isCurrent)
                self.navigationController?.pushViewController(deviceBackupPhoneDtailsViewController, animated: true)
            default: break
            }
        }
//        if indexPath.section == 0{
//            switch indexPath.row {
//            case 0:
//
//            default:
//                let deviceBackupPhoneDtailsViewController = DeviceBackupPhoneDtailsViewController.init(style:.highHeight)
//                let tab = retrieveTabbarController()
//                deviceBackupPhoneDtailsViewController.largeTitle = "iphone XR"
//                tab?.setTabBarHidden(true, animated: true)
//                self.navigationController?.pushViewController(deviceBackupPhoneDtailsViewController, animated: true)
//            }
//        }else{
//            let deviceBackupPCDtailsViewController = DeviceBackupPhoneDtailsViewController.init(style:.highHeight)
//            deviceBackupPCDtailsViewController.largeTitle = "MAC"
//            let tab = retrieveTabbarController()
//            tab?.setTabBarHidden(true, animated: true)
//            self.navigationController?.pushViewController(deviceBackupPCDtailsViewController, animated: true)
//        }
    }
}


