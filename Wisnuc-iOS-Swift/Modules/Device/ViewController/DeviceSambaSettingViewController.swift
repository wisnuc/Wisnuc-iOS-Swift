//
//  DeviceSambaSettingViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/18.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class DeviceSambaSettingViewController: BaseViewController {

    let identifier = "celled"
    let cellHeight:CGFloat = 48
    let headerHeight:CGFloat = 48
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.largeTitle = LocalizedString(forKey: "SAMBA设置")
        self.view.addSubview(infoSettingTableView)
        self.view.bringSubview(toFront: appBar.appBarViewController.headerView)
        headerContentLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.trackingScrollView = self.infoSettingTableView
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = true
        ViewTools.automaticallyAdjustsScrollView(scrollView: self.infoSettingTableView, viewController: self)
    }
    
    func headerContentLayout(){
        barMaximumHeight = 170
        appBar.headerViewController.headerView.maximumHeight = barMaximumHeight
        self.largeDetailTextLabel.text = LocalizedString(forKey: "可提升用户防御能力")
        appBar.headerStackView.addSubview(self.largeDetailTextLabel)
        largeTitleLabel.frame =  CGRect(x: MarginsWidth, y: self.largeDetailTextLabel.top - 20 - MarginsWidth, width: __kWidth - MarginsWidth*2, height: 20)
    }
    
    @objc func rightBarButtonItemTap(_ sender:UIBarButtonItem){
        let configNetVC = ConfigNetworkViewController.init(style: .whiteWithoutShadow ,state:.change )
        self.navigationController?.pushViewController(configNetVC, animated: true)
    }
    
    @objc func switchBtnHandle(_ sender:UISwitch){
       
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
    
    lazy var largeDetailTextLabel: UILabel = { [weak self] in
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: (self?.barMaximumHeight)! - 14 - 20 - 32, width: __kWidth - MarginsWidth*2, height: 14))
        label.textColor = LightGrayColor
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
}

extension DeviceSambaSettingViewController:UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.zero)
        headerView.backgroundColor = lightGrayBackgroudColor
        let lineView = UIView.init(frame: CGRect(x: MarginsWidth + 4, y: headerHeight - 1, width: __kWidth - ((MarginsWidth + 4)*2), height: 1))
        lineView.backgroundColor = Gray6Color
        let headerBackgroudView = UIView.init(frame: CGRect(x: 0, y: 8, width: __kWidth, height: headerHeight - 8))
        headerBackgroudView.backgroundColor = .white
        headerView.addSubview(headerBackgroudView)
        
        let leftLabel = UILabel.init(frame: CGRect(x: MarginsWidth + 4, y: headerBackgroudView.height/2 - 14/2, width: __kWidth/2 - MarginsWidth, height: 14))
        leftLabel.textColor = LightGrayColor
        leftLabel.font = UIFont.systemFont(ofSize: 14)
        headerBackgroudView.addSubview(leftLabel)
        
        if section == 0{
            leftLabel.text = LocalizedString(forKey: "共享空间")
        }else{
            leftLabel.text = LocalizedString(forKey: "Samba密码")
        }
        headerView.addSubview(lineView)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: identifier)
        tableView.separatorStyle = .none
        if indexPath.section == 0{
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = LocalizedString(forKey:"允许匿名访问")
                cell.textLabel?.textColor = DarkGrayColor
                cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
                let switchBtn = UISwitch.init()
                switchBtn.center = CGPoint.init(x: __kWidth - 16 - switchBtn.width/2, y: cell.height/2)
//                switchBtn.isOn = autoBackupSwitchOn
                switchBtn.addTarget(self, action: #selector(switchBtnHandle(_ :)), for: UIControlEvents.valueChanged)
                if(!AppUserService.isUserLogin){
                    switchBtn.isEnabled = false
                }
                cell.contentView.addSubview(switchBtn)
            default:
                break
            }
            
        }else{
            cell.textLabel?.text = LocalizedString(forKey:"通过密码访问个人数据")
            cell.textLabel?.textColor = DarkGrayColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            cell.accessoryType = .disclosureIndicator
        }
      
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1{
           let verificationCodeViewController =  MyVerificationCodeViewController.init(style: NavigationStyle.whiteWithoutShadow, state: .phone, nextState: .setSamba)
            self.navigationController?.pushViewController(verificationCodeViewController, animated: true)
        }
    }
}

extension DeviceSambaSettingViewController{
  
    override func flexibleHeaderViewFrameDidChange(_ headerView: MDCFlexibleHeaderView) {
//        //       print(headerView.bottom)
        let viewOriginY:CGFloat = self.barMaximumHeight - 14 - kStatusBarHeight - 32 - 20 - MarginsWidth
        let viewOriginX:CGFloat = MarginsWidth
        //        print(headerView.bottom - headerView.maximumHeight)
        if headerView.maximumHeight > headerView.bottom{
            self.largeTitleLabel.origin.y = viewOriginY + (0.55*(headerView.bottom - headerView.maximumHeight))
            self.largeTitleLabel.origin.x = viewOriginX - (0.55*(headerView.bottom - headerView.maximumHeight))
            self.largeDetailTextLabel.alpha = 0
        }else{
            self.largeTitleLabel.origin.y = viewOriginY + (headerView.bottom - headerView.maximumHeight)
            self.largeDetailTextLabel.alpha = 1
        }
    }
}
