//
//  DeviceUsersManageViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/17.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class DeviceUsersManageViewController: BaseViewController {
    let identifier = "celled"
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigation()
        self.largeTitle = LocalizedString(forKey: "设备用户")
        self.view.addSubview(infoSettingTableView)
        self.view.bringSubview(toFront: appBar.appBarViewController.headerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.trackingScrollView = self.infoSettingTableView
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = true
        ViewTools.automaticallyAdjustsScrollView(scrollView: self.infoSettingTableView, viewController: self)
    }
    
    @objc func addUserBarButtonItemTap(_ sender:UIBarButtonItem){
        let addUserSettingViewController = DeviceAddUserSettingViewController.init(style:.highHeight)
        self.navigationController?.pushViewController(addUserSettingViewController, animated: true)
    }
    
    func prepareNavigation(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "add_user.png"), style: .plain, target: self, action: #selector(addUserBarButtonItemTap(_:)))
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

extension DeviceUsersManageViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: identifier)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "13176679901"
            cell.detailTextLabel?.text = "已用2.1GB"
            cell.imageView?.image = UIImage.init(named: "user_avatar_placeholder.png")
            cell.imageView?.was_setCircleImage(withUrlString: "", placeholder: UIImage.init(named: "user_avatar_placeholder.png"))
        case 1:
            cell.textLabel?.text = "13176679220"
            cell.detailTextLabel?.text = "已用10GB"
            cell.imageView?.image = UIImage.init(named: "user_avatar_placeholder.png")
            cell.imageView?.was_setCircleImage(withUrlString: "", placeholder: UIImage.init(named: "user_avatar_placeholder.png"))
        case 2:
            cell.textLabel?.text = "13988888888"
            cell.detailTextLabel?.text = "已用1GB"
            cell.imageView?.image = UIImage.init(named: "user_avatar_placeholder.png")
            cell.imageView?.was_setCircleImage(withUrlString: "", placeholder: UIImage.init(named: "user_avatar_placeholder.png"))
        default:
            break
        }
        cell.separatorInset = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 0)
        cell.textLabel?.textColor = DarkGrayColor
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cell.detailTextLabel?.textColor = LightGrayColor
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.default, title: LocalizedString(forKey: "删除")) { [weak self](tableViewForAction, indexForAction) in
//            let index = indexForAction.row
//            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        deleteRowAction.backgroundColor = UIColor.red

        return [deleteRowAction]
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
