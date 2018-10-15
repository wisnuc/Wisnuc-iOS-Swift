//
//  DeviceChangeDeviceViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/15.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class DeviceChangeDeviceViewController: BaseViewController {
    let identifier = "celled"
    let cellHeight:CGFloat = 173
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigationBar()
        self.view.addSubview(deviveTabelView)
        appBar.headerViewController.headerView.trackingScrollView = deviveTabelView
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
    }
    
    func prepareNavigationBar(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "close_gray.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(dismiss(_ :)))
    }
    
    @objc func dismiss(_ sender:UIBarButtonItem){
        self.presentingViewController?.dismiss(animated: true, completion: {
            
        })
    }
    
    lazy var deviveTabelView: UITableView = { [weak self] in
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight), style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: StringExtension.classNameAsString(targetClass:DeviceChangeDeviceTableViewCell.self), bundle: nil), forCellReuseIdentifier: identifier)
        tableView.backgroundColor = .white
        return tableView
        }()
}

extension DeviceChangeDeviceViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            break
        default: break
            
        }
    }
}

extension DeviceChangeDeviceViewController:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DeviceChangeDeviceTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DeviceChangeDeviceTableViewCell
        tableView.separatorStyle = .none
        cell.selectionStyle = .none
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = "Wisnuc Office"
            cell.capacityLabel.text = "4M / 1T"
            cell.disable = false
        case 1:
            cell.titleLabel.text = "Wisnuc New"
            cell.capacityLabel.text = "256G / 2T"
            cell.disable = false
        case 2:
            cell.titleLabel.text = "Wisnuc Disable"
            cell.capacityLabel.text = "10G / 1T"
            cell.disable = true
        default: break
            
        }
        return cell
    }
    
}
