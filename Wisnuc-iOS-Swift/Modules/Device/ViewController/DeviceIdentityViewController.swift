//
//  DeviceIdentityViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/17.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class DeviceIdentityViewController: BaseViewController {
    var model:WinasdInfoModel?
    let identifier = "celled"
    
    
    init(style: NavigationStyle,model:WinasdInfoModel) {
        super.init(style: style)
        self.model = model
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.largeTitle = LocalizedString(forKey: "设备身份")
        self.view.addSubview(infoSettingTableView)
        self.view.bringSubview(toFront: appBar.appBarViewController.headerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.trackingScrollView = self.infoSettingTableView
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = true
        ViewTools.automaticallyAdjustsScrollView(scrollView: self.infoSettingTableView, viewController: self)
    }
    
    lazy var infoSettingTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight), style: UITableViewStyle.plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        return tableView
    }()
}

extension DeviceIdentityViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: identifier)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = LocalizedString(forKey: "设备SN")
            cell.detailTextLabel?.text = model?.device?.sn
        case 1:
            cell.textLabel?.text = LocalizedString(forKey:"证书")
            cell.detailTextLabel?.text = model?.device?.cert
        case 2:
            cell.textLabel?.text = LocalizedString(forKey:"证书指纹")
            cell.detailTextLabel?.text = model?.device?.fingerprint
        case 3:
            cell.textLabel?.text = LocalizedString(forKey:"证书签发身份")
            cell.detailTextLabel?.text = model?.device?.signer
        case 4:
            cell.textLabel?.text = LocalizedString(forKey:"证书签发时间")
            if let notBefore = model?.device?.notBefore{
            cell.detailTextLabel?.text = TimeTools.timeString(TimeInterval.init(notBefore)/1000 , formatterString: "yyyy-MM-dd")
            }
        default:
            break
        }
        
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
