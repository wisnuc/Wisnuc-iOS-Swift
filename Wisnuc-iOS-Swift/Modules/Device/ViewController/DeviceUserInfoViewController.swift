//
//  DeviceUserInfoViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/18.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class DeviceUserInfoViewController: BaseViewController {
    let identifier = "celled"
    let cellHeight:CGFloat = 48
    let headerHeight:CGFloat = 48
    
    init(style: NavigationStyle,phone:String,avatar:String?) {
        self.largeTitle = phone
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigationBar()
        
        self.view.addSubview(infoSettingTableView)
        self.view.bringSubview(toFront: appBar.appBarViewController.headerView)
        headerContentLayout()
    }
    
    @objc func dismiss(_ sender:UIBarButtonItem){
        self.navigationController?.presentingViewController?.dismiss(animated: true, completion: {
            
        })
    }
    
    func prepareNavigationBar(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "close_gray.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(dismiss(_ :)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.trackingScrollView = self.infoSettingTableView
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = true
        ViewTools.automaticallyAdjustsScrollView(scrollView: self.infoSettingTableView, viewController: self)
    }
    
    func headerContentLayout(){
        appBar.headerStackView.addSubview(self.avatarImageView)
        largeTitleLabel.frame = CGRect(x: self.avatarImageView.right + 10, y: barMaximumHeight - 20 - 20 - 20, width: __kWidth - MarginsWidth*2, height: 20)
    }
    
    @objc func rightBarButtonItemTap(_ sender:UIBarButtonItem){
        let configNetVC = ConfigNetworkViewController.init(style: .whiteWithoutShadow ,state:.change )
        self.navigationController?.pushViewController(configNetVC, animated: true)
    }
    
    
    @objc func switchBtnHandleForUSB(_ sender:UISwitch){
        
    }
    
    @objc func switchBtnHandleForShare(_ sender:UISwitch){
        
    }
    
    
    lazy var infoSettingTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight), style: UITableViewStyle.grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.sectionFooterHeight = 0.001
        tableView.backgroundColor = .white
        return tableView
    }()
    
    lazy var avatarImageView: UIImageView = { [weak self] in
        let width:CGFloat = 40
        let imageView = UIImageView.init(frame: CGRect(x: MarginsWidth, y: (self?.barMaximumHeight)! - 8 - width - 20 , width: width, height: width))
       imageView.image =  UIImage.init(named: "user_avatar_placeholder.png")
        return imageView
        }()
}

extension DeviceUserInfoViewController:UITableViewDataSource,UITableViewDelegate{
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
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.zero)
        headerView.backgroundColor = lightGrayBackgroudColor
        let lineView = UIView.init(frame: CGRect(x: MarginsWidth + 2, y: headerHeight - 1, width: __kWidth - ((MarginsWidth + 4)*2), height: 1))
        lineView.backgroundColor = Gray6Color
        let headerBackgroudView = UIView.init(frame: CGRect(x: 0, y: 8, width: __kWidth, height: headerHeight - 8))
        headerBackgroudView.backgroundColor = .white
        headerView.addSubview(headerBackgroudView)
        
        let leftLabel = UILabel.init(frame: CGRect(x: MarginsWidth + 2, y: headerBackgroudView.height/2 - 14/2, width: __kWidth/2 - MarginsWidth, height: 14))
        leftLabel.textColor = LightGrayColor
        leftLabel.font = UIFont.systemFont(ofSize: 14)
        headerBackgroudView.addSubview(leftLabel)
        
        if section == 0{
            leftLabel.text = LocalizedString(forKey: "共享空间")
        }else{
            leftLabel.text = LocalizedString(forKey: "共用空间")
        }
//        headerView.addSubview(lineView)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
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
                switchBtn.isOn = false
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
       
    }
}

extension DeviceUserInfoViewController{
    
    override func flexibleHeaderViewFrameDidChange(_ headerView: MDCFlexibleHeaderView) {
        //        //       print(headerView.bottom)
        let viewOriginY:CGFloat = self.barMaximumHeight - 20 - 20 - 20
        let viewOriginX:CGFloat = self.avatarImageView.right + 10
        //        print(headerView.bottom - headerView.maximumHeight)
        if headerView.maximumHeight > headerView.bottom{
            self.largeTitleLabel.origin.y = viewOriginY + (headerView.bottom - headerView.maximumHeight)
//            self.largeTitleLabel.origin.x = viewOriginX + (0.55*(headerView.bottom - headerView.maximumHeight))
            
            self.avatarImageView.alpha = 0
        }else{
            self.largeTitleLabel.origin.y = viewOriginY + (headerView.bottom - headerView.maximumHeight)
            self.avatarImageView.alpha = 1
        }
    }
}
