//
//  DevicePeripheralDeviceViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/17.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class DevicePeripheralDeviceViewController: BaseViewController {
    let identifier = "celled"
    let headerHeight:CGFloat = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigation()
        self.largeTitle = LocalizedString(forKey: "USB设备")
        self.view.addSubview(peripheralTableView)
        self.view.bringSubview(toFront: appBar.appBarViewController.headerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.trackingScrollView = self.peripheralTableView
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = true
        ViewTools.automaticallyAdjustsScrollView(scrollView: self.peripheralTableView, viewController: self)
    }
    
    @objc func rightBarButtonItemTap(_ sender:UIBarButtonItem){
        self.alertControllerActionSheet( action1Title: "Kingston", action1Handler: { (alertAction1) in
            
        }, action2Title: "Kingston_2") { (alertAction2) in
            
        }
    }
    
    func prepareNavigation(){
        let rightBarButtonItem = UIBarButtonItem.init(title: LocalizedString(forKey: "弹出"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightBarButtonItemTap(_:)))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    lazy var peripheralTableView: UITableView = {
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

extension DevicePeripheralDeviceViewController:UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 2
        }else{
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
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
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = LocalizedString(forKey: "设备1：Kingston")
                cell.detailTextLabel?.text = "总容量2TB"
            case 1:
                cell.textLabel?.text =  "Kingston"
                cell.detailTextLabel?.text = "已用5.4GB"
            default:
                break
            }
            
             cell.textLabel?.textColor = DarkGrayColor
        }else{
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "设备2：Kingston_2"
                cell.detailTextLabel?.text = "总容量4TB"
            case 1:
                cell.textLabel?.text =  "Kingston(A)"
                cell.detailTextLabel?.text = "已用45.4GB"
            case 2:
                cell.textLabel?.text = "Kingston(B)"
                cell.detailTextLabel?.text = "已用45.4GB"
                
            default:
                break
            }
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



