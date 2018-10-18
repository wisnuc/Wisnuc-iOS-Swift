//
//  DeviceAddDeviceViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/17.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class DeviceAddDeviceViewController: BaseViewController {
    let identifier = "celled"
    let cellHeight:CGFloat = 64
    override func viewDidLoad() {
        super.viewDidLoad()
        self.largeTitle = LocalizedString(forKey: "添加设备")
        prepareNavigationBar()
        self.view.addSubview(infoSettingTableView)
        self.view.bringSubview(toFront: appBar.appBarViewController.headerView)
      
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.trackingScrollView = self.infoSettingTableView
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = true
        ViewTools.automaticallyAdjustsScrollView(scrollView: self.infoSettingTableView, viewController: self)
    }
    
    @objc func dismiss(_ sender:UIBarButtonItem){
        self.presentingViewController?.dismiss(animated: true, completion: {
            
        })
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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "close_gray.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(dismiss(_ :)))
    }
    
    lazy var infoSettingTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight), style: UITableViewStyle.plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: StringExtension.classNameAsString(targetClass: DeviceAddDeviceTableViewCell.self), bundle: nil), forCellReuseIdentifier: identifier)
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        return tableView
    }()
}

extension DeviceAddDeviceViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DeviceAddDeviceTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DeviceAddDeviceTableViewCell
        cell.selectionStyle = .none
        switch indexPath.row {
        case 0:
            cell.nameLabel.text = LocalizedString(forKey: "Wisnuc Office")
            cell.detailLabel.text = LocalizedString(forKey:"当前连接")
        case 1:
            cell.nameLabel.text = LocalizedString(forKey: "Wisnuc-1")
            cell.detailLabel.text = LocalizedString(forKey:"脱机")
             cell.disabled = true
        case 2:
            cell.nameLabel.text = LocalizedString(forKey: "Wisnuc-2")
            cell.detailLabel.text = LocalizedString(forKey:"在线")
        case 3:
            cell.nameLabel.text = LocalizedString(forKey: "Wisnuc-3")
            cell.detailLabel.text = LocalizedString(forKey:"关机")
            cell.disabled = true
            default:
                break
            }
        
        if cell.isSelected {
             cell.selectButton.isSelected = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let cell:DeviceAddDeviceTableViewCell = tableView.cellForRow(at: indexPath) as! DeviceAddDeviceTableViewCell
        for (i,value) in (cells(for: tableView)?.enumerated())! {
            if i != indexPath.row {
                value.isSelected = false
            } else if i == indexPath.row {
                value.isSelected = true
            }
        }
    }
}
