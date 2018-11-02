//
//  SettingRootViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/8/15.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Kingfisher

class SettingRootViewController: BaseViewController {
    let identifier = "Cellidentifier"
    let cellHeight:CGFloat = 52
    let headerHeight:CGFloat = 126 + 32 + 36 + 8
    var autoBackupSwitchOn = false
    var wifiSwitchOn = true
    override func viewDidLoad() {
        super.viewDidLoad()
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
//        appBar.headerViewController.headerView.isHidden = true
        if let controller = UIViewController.currentViewController(){
            if !(controller is SettingRootViewController){
                return
            }
        }
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
            AppService.sharedInstance().startAutoBackup {
            }
        } else{
            AppService.sharedInstance().autoBackupManager.stop()
        }
    }
    
    @objc func switchBtnHandleForWIFISync(_ sender:UISwitch){
        AppUserService.currentUser?.isWIFIAutoBackup = NSNumber.init(value: sender.isOn)
        AppUserService.synchronizedCurrentUser()
        wifiSwitchOn = sender.isOn
        if wifiSwitchOn {
          
        } else{
           
        }
    }
    
    @objc func myInfoViewTap(_ sender:UIGestureRecognizer){
        if let tab = retrieveTabbarController(){
            tab.setTabBarHidden(true, animated: true)
        }
        let myInfoVC = MyInfoCenterViewController.init(style: NavigationStyle.whiteWithoutShadow)
        self.navigationController?.pushViewController(myInfoVC, animated: true)
    }
    
    
    @objc func secureHighViewTap(_ sender:UIGestureRecognizer){
        if let tab = retrieveTabbarController(){
            tab.setTabBarHidden(true, animated: true)
        }
        let secureStepVC = MySecureStepViewController.init(style: NavigationStyle.whiteWithoutShadow)
        self.navigationController?.pushViewController(secureStepVC, animated: true)
    }
    
    func logoutAction(){
        AppUserService.logoutUser()
        AppService.sharedInstance().abort()
        appDelegate.initRootVC()
    }
    
    func setHeaderContent(){
        headerDetailLabel.text = LocalizedString(forKey: "查看并编辑个人资料")
        headerDetailLabel.font = UIFont.systemFont(ofSize: 14)
        headerDetailLabel.textColor = DarkGrayColor
        myInfoView.addSubview(headerDetailLabel)
        
        headerTitleLabel.text = LocalizedString(forKey: "13929900902")
        headerTitleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        headerTitleLabel.textColor = DarkGrayColor
        myInfoView.addSubview(headerTitleLabel)
        
        avatarImageView.image = UIImage.init(named: "avatar_placeholder.png")
        myInfoView.addSubview(avatarImageView)
        
        headerTipsLabel.text = LocalizedString(forKey: "提高安全性还有1步")
        headerTipsLabel.font = UIFont.systemFont(ofSize: 18)
        headerTipsLabel.textColor = DarkGrayColor
        
        //        headerTipsView.backgroundColor = .red
        headerTipsView.addSubview(headerTipsLabel)
        headerTipsView.addSubview(secureProgressView)
        headerTipsView.isUserInteractionEnabled = true

        secureProgressView.transform = CGAffineTransform.init(scaleX: 1.0, y: 10.0)
        secureProgressView.progressTintColor = UIColor.colorFromRGB(rgbValue: 0x0f9a825)
        secureProgressView.trackTintColor = Gray12Color
        secureProgressView.progress = 0.5
        headerView.addSubview(myInfoView)
        headerView.addSubview(headerTipsView)
        headerView.addSubview(secureHighView)
    }
    
    lazy var settingTabelView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight), style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.tableFooterView = UIView.init()
        tableView.backgroundColor = .white
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    lazy var headerView: UIView = {
        let view = UIView.init(frame: CGRect.zero)
//        view.backgroundColor = .red
        return view
    }()
    
    lazy var myInfoView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 5, width: __kWidth, height: 56))
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(myInfoViewTap(_ :)))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    lazy var headerTipsView: UIView =  UIView.init(frame: CGRect(x: 0, y: self.myInfoView.bottom + 36, width: __kWidth, height: 62))
    
    lazy var headerDetailLabel = UILabel.init(frame: CGRect(x: MarginsWidth, y: myInfoView.height - 3 - 15, width: __kWidth - 60, height: 15))
    
    lazy var headerTitleLabel = UILabel.init(frame: CGRect(x: MarginsWidth, y: headerDetailLabel.top - 30 - MarginsWidth, width: __kWidth - 60, height: 30))
    
    lazy var avatarImageView = UIImageView.init(frame: CGRect(x: __kWidth - MarginsWidth - 56, y: myInfoView.height - 56, width: 56, height: 56))
    
    lazy var headerTipsLabel = UILabel.init(frame: CGRect(x: MarginsWidth, y: 6, width: __kWidth - 60, height: 18))
    
    lazy var secureProgressView = UIProgressView.init(frame: CGRect(x: MarginsWidth, y: headerTipsLabel.bottom + MarginsCloseWidth + 8, width: __kWidth - MarginsWidth*2, height: 24))
    
    lazy var cacheLabel: UILabel = {
        let width = __kWidth/2
        let height:CGFloat = 14
        
        let label = UILabel.init(frame: CGRect(x: __kWidth - 16 - width, y: cellHeight/2 - height/2, width: width, height: height))
        label.textColor = LightGrayColor
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()
    
    lazy var secureHighView: UIView = { [weak self] in
        let view = UIView.init(frame: CGRect(x: 0, y: (self?.headerTipsView.bottom)! + 1, width: __kWidth, height: 32))
        
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: 0, width: __kWidth - MarginsWidth*2 - 40, height: 32))
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = LocalizedString(forKey: "去提高安全性")
        label.textColor = DarkGrayColor
        view.addSubview(label)
        
        let imageView = UIImageView.init(frame: CGRect(x: __kWidth - 24 - MarginsWidth + 4, y: view.height/2 - 24/2, width: 24, height: 24))
        imageView.image = UIImage.init(named: "cell_arrow.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        imageView.tintColor = LightGrayColor
        view.addSubview(imageView)
        
        view.isUserInteractionEnabled = true
        let tapGestrue = UITapGestureRecognizer.init(target: self, action: #selector(secureHighViewTap(_ :)))
        view.addGestureRecognizer(tapGestrue)
        return view
    }()
}

extension SettingRootViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let myAccountSecurityViewController = MyAccountSecurityViewController.init(style:NavigationStyle.whiteWithoutShadow)
            self.navigationController?.pushViewController(myAccountSecurityViewController, animated: true)
            if let tab = retrieveTabbarController(){
                tab.setTabBarHidden(true, animated: true)
            }
        case 1:
            let settingLanguageViewController = SettingLanguageViewController.init(style:NavigationStyle.whiteWithoutShadow)
            self.navigationController?.pushViewController(settingLanguageViewController, animated: true)
            if let tab = retrieveTabbarController(){
                tab.setTabBarHidden(true, animated: true)
            }
        case 2:
            YYImageCache.shared().diskCache.removeAllObjects {
               
            }
            
            KingfisherManager.shared.cache.clearDiskCache()
            self.settingTabelView.reloadData()

        case 3:
            let myAboutViewController = MyAboutViewController.init(style:NavigationStyle.whiteWithoutShadow)
            self.navigationController?.pushViewController(myAboutViewController, animated: true)
            if let tab = retrieveTabbarController(){
                tab.setTabBarHidden(true, animated: true)
            }
        case 4:
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
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        setHeaderContent()
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = LocalizedString(forKey: "账户安全")
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.textLabel?.textColor = DarkGrayColor
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        case 1:
            cell.textLabel?.text = LocalizedString(forKey: "语言")
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.textLabel?.textColor = DarkGrayColor
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        case 2:
            cell.textLabel?.text = LocalizedString(forKey: "清除缓存")
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.textLabel?.textColor = DarkGrayColor
            cell.contentView.addSubview(cacheLabel)
            
            var i =  YYImageCache.shared().diskCache.totalCost()
             KingfisherManager.shared.cache.calculateDiskCacheSize(completion: { [weak self] (size) in
                i = i + Int(size)
                self?.cacheLabel.text = sizeString(Int64(i))
            })
            print(String(format: "%ld", Int(YYImageCache.shared().diskCache.totalCost())))
           cacheLabel.text = sizeString(Int64(i))
           
         
            
//            let switchBtn = UISwitch.init()
//            switchBtn.center = CGPoint.init(x: __kWidth - 16 - switchBtn.width/2, y: cell.height/2)
//            switchBtn.isOn = autoBackupSwitchOn
//            switchBtn.addTarget(self, action: #selector(switchBtnHandleForSync(_ :)), for: UIControlEvents.valueChanged)
//            if(!AppUserService.isUserLogin)
//            {switchBtn.isEnabled = false}
//            cell.contentView.addSubview(switchBtn)
            
            
        case 3:
            cell.textLabel?.text = LocalizedString(forKey: "关于")
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.textLabel?.textColor = DarkGrayColor
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
//            let switchBtn = UISwitch.init()
//            switchBtn.center = CGPoint.init(x: __kWidth - 16 - switchBtn.width/2, y: cell.height/2)
//            switchBtn.isOn = wifiSwitchOn
//            switchBtn.addTarget(self, action: #selector(switchBtnHandleForWIFISync(_ :)), for: UIControlEvents.valueChanged)
//            if(!AppUserService.isUserLogin)
//            {switchBtn.isEnabled = false}
//            cell.contentView.addSubview(switchBtn)
        case 4:
            cell.textLabel?.text = LocalizedString(forKey: "Log out")
        default: break
            
        }
        return cell
    }

}
