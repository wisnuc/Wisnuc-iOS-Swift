//
//  LoginSelectionDeviceViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/11/7.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class LoginSelectionDeviceViewController: BaseViewController {
    let identifier = "celled"
    let cellHeight:CGFloat = 64
    let headerHeight:CGFloat = 56 + 16 + 32
    let footerHeight:CGFloat = 16 + 49
    var devices:[StationsInfoModel]?
    var userId:String?
    var selectedModel:StationsInfoModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigationBar()
        self.view.addSubview(infoSettingTableView)
        self.view.bringSubview(toFront: appBar.appBarViewController.headerView)
        // Do any additional setup after loading the view.
    }
    
    init(style: NavigationStyle,devices:[StationsInfoModel],userId:String) {
        super.init(style: style)
        self.devices = devices
        self.userId = userId
    }
    
    func confirmButtonNormal(){
        confirmButton.isEnabled = true
        confirmButton.layer.borderColor = COR1.cgColor
        confirmButton.layer.borderWidth = 1
    }
    
    func confirmButtonDisabled(){
        confirmButton.isEnabled = false
        confirmButton.layer.borderColor = LightGrayColor.cgColor
        confirmButton.layer.borderWidth = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.trackingScrollView = self.infoSettingTableView
        appBar.navigationBar.tintColor = COR1
//        appBar.headerViewController.headerView.tintColor = LightGrayColor
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = true
        ViewTools.automaticallyAdjustsScrollView(scrollView: self.infoSettingTableView, viewController: self)
    }
    
    @objc func addDeviceTap(_ sender:UIBarButtonItem){
        alertControllerActionSheet(title: nil, message: nil, cancelActionTitle: LocalizedString(forKey: "取消"), action1Title: LocalizedString(forKey: "添加新设备"), action1Handler: { (alertAction1) in
            
        }, action2Title: LocalizedString(forKey: "扫一扫，添加他人设备")) { (alertAction2) in
            
        }
    }
    
    @objc func dismiss(_ sender:UIBarButtonItem){
        self.presentingViewController?.dismiss(animated: true, completion: {
            AppUserService.logoutUser()
        })
    }
    
    @objc func confirmButtonTap(_ sender:UIButton){
        ActivityIndicator.startActivityIndicatorAnimation()
        if let userId = self.userId {
            if let model = self.selectedModel,let user = AppUserService.user(uuid: userId){
                AppService.sharedInstance().loginAction(stationModel: model, orginTokenUser: user) { (error, userData) in
                    if error == nil && userData != nil{
                        AppUserService.setCurrentUser(userData)
                        AppUserService.synchronizedCurrentUser()
                        appDelegate.initRootVC()
                    }else{
                        if error != nil{
                            switch error {
                            case is LoginError:
                                let loginError = error as! LoginError
                                Message.message(text: loginError.localizedDescription, duration: 2.0)
                            case is BaseError:
                                let baseError = error as! BaseError
                                Message.message(text: baseError.localizedDescription, duration: 2.0)
                            default:
                                Message.message(text: (error?.localizedDescription)!, duration: 2.0)
                            }
                            AppUserService.logoutUser()
                        }
                    }
                }
                ActivityIndicator.stopActivityIndicatorAnimation()
            }else{
                AppUserService.logoutUser()
                Message.message(text: ErrorLocalizedDescription.Login.NoCurrentUser, duration: 2.0)
                ActivityIndicator.stopActivityIndicatorAnimation()
            }
        }else{
            Message.message(text: ErrorLocalizedDescription.Login.NoCurrentUser, duration: 2.0)
            ActivityIndicator.stopActivityIndicatorAnimation()
            AppUserService.logoutUser()
        }
    }
    
    func cells(for tableView: UITableView) -> [DeviceAddDeviceTableViewCell]? {
        let sections: Int = tableView.numberOfSections
        var cells: [DeviceAddDeviceTableViewCell] = []
        for section in 0..<sections {
            let rows: Int = tableView.numberOfRows(inSection: section)
            for row in 0..<rows {
                let indexPath = IndexPath(row: row, section: section)
                if let aPath = tableView.cellForRow(at: indexPath){
                    cells.append(aPath as! DeviceAddDeviceTableViewCell)
                }
            }
        }
        return cells
    }
    
    func prepareNavigationBar(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: LocalizedString(forKey: "退出登录"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(dismiss(_ :)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "add_gray.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addDeviceTap(_ :)))
        
    }
    
    lazy var headerTitleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: MarginsWidth, width: __kWidth - MarginsWidth*2, height: 56))
        label.textColor = DarkGrayColor
        label.font = UIFont.systemFont(ofSize: 21)
        label.text = LocalizedString(forKey: "主人，上次登录的设备已关机\n可尝试连接以下设备")
        label.numberOfLines = 0
        return label
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton.init(frame: CGRect(x: MarginsWidth, y: MarginsWidth, width: __kWidth - MarginsWidth*2, height: 48))
        button.setTitle(LocalizedString(forKey: "确定"), for: UIControlState.normal)
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        button.setTitleColor(LightGrayColor, for: UIControlState.disabled)
        button.setBackgroundImage(UIImage.init(color: COR1), for: UIControlState.normal)
        button.setBackgroundImage(UIImage.init(color: UIColor.white), for: UIControlState.disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 48/2
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(confirmButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var infoSettingTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight), style: UITableViewStyle.grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: StringExtension.classNameAsString(targetClass: DeviceAddDeviceTableViewCell.self), bundle: nil), forCellReuseIdentifier: identifier)
        tableView.backgroundColor = .white
        return tableView
    }()
}

extension LoginSelectionDeviceViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.addSubview(headerTitleLabel)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init()
        view.addSubview(confirmButton)
        confirmButtonDisabled()
        return view
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DeviceAddDeviceTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DeviceAddDeviceTableViewCell
        cell.selectionStyle = .none
        let model = devices![indexPath.row]
        cell.nameLabel.text = model.sn
        if let onlineNumber = model.online{
            if let online = Bool.init(exactly: NSNumber.init(value: onlineNumber)){
            cell.detailLabel.text = online ? LocalizedString(forKey:"在线") : LocalizedString(forKey:"关机")
            cell.disabled = !online
            }
        }
        if cell.isSelected {
            cell.selectButton.isSelected = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        tableView.deselectRow(at: indexPath, animated: true)
        let cell:DeviceAddDeviceTableViewCell = tableView.cellForRow(at: indexPath) as! DeviceAddDeviceTableViewCell
        let model = devices![indexPath.row]
        for (i,value) in (cells(for: tableView)?.enumerated())! {
            if i != indexPath.row {
                value.isSelected = false
            } else if i == indexPath.row {
                value.isSelected = true
            }
        }
        if cell.isSelected && !cell.disabled{
            confirmButtonNormal()
            self.selectedModel = model
        }
    }
}
