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
    var headerHeight:CGFloat = 126 + 32 + 36 + 8
    let noTipsHeaderHeight:CGFloat = 70 + 8
    let normalHeaderHeight:CGFloat = 126 + 32 + 36 + 8
    var autoBackupSwitchOn = false
    var wifiSwitchOn = true
    override func viewDidLoad() {
        super.viewDidLoad()
        appBar.headerViewController.headerView.trackingScrollView = settingTabelView
        self.view.addSubview(settingTabelView)
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        AppUserService.updateCurrentUserInfo {
            self.setAvatar()
            self.setHeaderTitle()
        }
        
        if  AppUserService.currentUser?.mail != nil{
            self.setHeaderTipsSecureHighView(isHidden: true)
        }
        
        setCacheSize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        getMail(complete: { [weak self](isBind) in
            if isBind{
                self?.setHeaderTipsSecureHighView(isHidden: true,reload:true)
            }else{
                self?.setHeaderTipsSecureHighView(isHidden: false,reload:true)
            }
        }) { [weak self] in
            self?.setHeaderTipsSecureHighView(isHidden: false,reload:true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     
        self.setAvatar()
        self.setHeaderTitle()
        self.settingTabelView.reloadData()
    }
    
    func setSwitchState(){
        autoBackupSwitchOn = AppUserService.currentUser?.autoBackUp?.boolValue ?? false
        wifiSwitchOn = AppUserService.currentUser?.isWIFIAutoBackup?.boolValue ?? true
    }
    
    func setCacheSize(){
        DispatchQueue.global(qos: .default).async {
            var i =  YYImageCache.shared().diskCache.totalCost()
            KingfisherManager.shared.cache.calculateDiskCacheSize(completion: {(size) in
                SDImageCache.shared().calculateSize(completionBlock: { (count, totalSize) in
                    i = i + Int(size) + Int(totalSize)
                    DispatchQueue.main.async {
                        self.cacheLabel.text = sizeString(Int64(i))
                    }
                })
            })
            DispatchQueue.main.async {
                self.cacheLabel.text = sizeString(Int64(i))
            }
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
    
    //设置头像
    func setAvatar(){
        let imageURL = URL.init(string: AppUserService.currentUser?.avaterURL ?? "")
        avatarImageView.setImageWith(imageURL, placeholder: UIImage.init(named: "avatar_placeholder_big.png"))
        avatarImageView.layer.cornerRadius = avatarImageView.width/2
        avatarImageView.clipsToBounds = true
    }
    
    func setHeaderTitle(){
        if let nickName = AppUserService.currentUser?.nickName {
             headerTitleLabel.text = nickName
        }else{
            if let userName = AppUserService.currentUser?.userName {
                headerTitleLabel.text = userName.replacePhone()
            }
        }
        headerTitleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        headerTitleLabel.textColor = DarkGrayColor
    }
    
    func setHeaderTipsSecureHighView(isHidden:Bool,reload:Bool? = nil){
        headerTipsView.isHidden = isHidden
        secureHighView.isHidden = isHidden
        headerHeight =  isHidden ? noTipsHeaderHeight : normalHeaderHeight
        if isHidden{
            headerTipsView.removeFromSuperview()
            secureHighView.removeFromSuperview()
        }else{
            headerView.addSubview(headerTipsView)
            headerView.addSubview(secureHighView)
        }
      
        if let reload = reload{
            if reload{
               self.settingTabelView.reloadData()
            }
        }
    }
    
    func setHeaderContent(){
        headerDetailLabel.text = LocalizedString(forKey: "查看并编辑个人资料")
        headerDetailLabel.font = UIFont.systemFont(ofSize: 14)
        headerDetailLabel.textColor = DarkGrayColor
        myInfoView.addSubview(headerDetailLabel)
        
        setHeaderTitle()
        myInfoView.addSubview(headerTitleLabel)
        
        setAvatar()
        myInfoView.addSubview(avatarImageView)
        
        headerTipsLabel.text = LocalizedString(forKey: "提高安全性还有1步")
        headerTipsLabel.font = UIFont.systemFont(ofSize: 18)
        headerTipsLabel.textColor = DarkGrayColor
       
        headerTipsView.addSubview(headerTipsLabel)
        headerTipsView.addSubview(secureProgressView)
        headerTipsView.isUserInteractionEnabled = true
        

        secureProgressView.transform = CGAffineTransform.init(scaleX: 1.0, y: 10.0)
        secureProgressView.progressTintColor = UIColor.colorFromRGB(rgbValue: 0x0f9a825)
        secureProgressView.trackTintColor = Gray12Color
        secureProgressView.progress = 0.5
        headerView.addSubview(myInfoView)

    }
    
    func getMail(complete:@escaping (_ isBind:Bool)->(),errorHandler:@escaping ()->()){
        UserMailAPI.init().startRequestJSONCompletionHandler {(response) in
            if let error = response.error {
                Message.message(text: error.localizedDescription)
                errorHandler()
            }else{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                    errorHandler()
                }else{
                    guard let jsonData = response.data else{
                      errorHandler()
                      return
                    }
                    do {
                        guard let stringDic = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String : Any] else{
                            errorHandler()
                          return
                        }
                        
                        if let mailArray = stringDic["data"] as? Array<[String:Any]>{
                            var mailDataArray = Array<UserMailModel>.init()
                            for value in mailArray{
                                if let mailModel = UserMailModel.deserialize(from: value) {
                                    mailDataArray.append(mailModel)
                                }
                            }
                            complete(mailDataArray.count > 0)
                        }
                        print(stringDic as Any)
                    } catch {
                        errorHandler()
                    }
                }
            }
        }
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
            //清除缓存
            SVProgressHUD.setDefaultStyle(.dark)
            SVProgressHUD.show(withStatus: LocalizedString(forKey: "正在清除缓存"))
            YYImageCache.shared().diskCache.removeAllObjects {
                SDImageCache.shared().clearDisk(onCompletion: {
                    KingfisherManager.shared.cache.clearDiskCache()
                    DispatchQueue.global(qos: .default).async {
                        self.setCacheSize()
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            self.settingTabelView.reloadData()
                        }
                    }
                })
            }
        case 3:
            let myAboutViewController = MyAboutViewController.init(style:NavigationStyle.whiteWithoutShadow)
            self.navigationController?.pushViewController(myAboutViewController, animated: true)
            if let tab = retrieveTabbarController(){
                tab.setTabBarHidden(true, animated: true)
            }
        case 4:
          AppService.sharedInstance().logoutAction()
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
         
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        case 1:
            cell.textLabel?.text = LocalizedString(forKey: "Language")
        
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        case 2:
            cell.textLabel?.text = LocalizedString(forKey: "清除缓存")
          
            cell.contentView.addSubview(cacheLabel)
            
        case 3:
            cell.textLabel?.text = LocalizedString(forKey: "About")
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        case 4:
            cell.textLabel?.text = LocalizedString(forKey: "Log out")
        default: break
            
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.textLabel?.textColor = DarkGrayColor
        return cell
    }

}
