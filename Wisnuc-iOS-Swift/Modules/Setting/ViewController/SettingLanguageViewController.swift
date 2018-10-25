//
//  SettingLanguageViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/25.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
enum LanguageType:Int64{
    case Chinese = 0
    case English
}

class SettingLanguageViewController: BaseViewController {
    var lastPath:IndexPath?
    let identifier = "cellIdentifier"
    let headerHeight:CGFloat = 64
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareNavigationBar()
        
        if AppUserService.currentUser?.language != nil {
            lastPath = IndexPath.init(row: (AppUserService.currentUser?.language?.intValue)!, section: 0)
        }else{
            lastPath = IndexPath.init(row: 0, section: 0)
        }
        
        self.view.addSubview(infoTableView)
        
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.trackingScrollView = self.infoTableView
        
    }
    
    @objc func dismiss(_ sender:UIBarButtonItem){
        self.presentingViewController?.dismiss(animated: true, completion: {
            
        })
    }
    
    
    func prepareNavigationBar(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "close_gray.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(dismiss(_ :)))
    }
    
    lazy var infoTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight), style: UITableViewStyle.plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: StringExtension.classNameAsString(targetClass: DeviceDetailInfdTableViewCell.self), bundle: nil), forCellReuseIdentifier: identifier)
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    lazy var headerView: UIView = {
        let view = UIView.init(frame: CGRect.zero)
        
        return view
    }()
    
    lazy var deviecNameLabel: UILabel = {
        let text = LocalizedString(forKey: "语言")
        let font = UIFont.boldSystemFont(ofSize: 21)
        let height = headerHeight
        let label = UILabel.init(frame: CGRect(x:MarginsWidth , y:0 , width: __kWidth - MarginsWidth*2, height: height))
        label.textColor = DarkGrayColor
        label.font = font
        label.text = text
        return label
    }()
    
}

extension SettingLanguageViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView.addSubview(deviecNameLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "中文"
        case 1:
            cell.textLabel?.text = "English"
        default:
            break
        }
        let row = indexPath.row
        
        let oldRow = lastPath?.row
        
        if (row == oldRow && lastPath != nil) {
            
            //这个是系统中对勾的那种选择框
            
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            
        }else{
            cell.accessoryType = UITableViewCellAccessoryType.none

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
        let newRow = indexPath.row
        let oldRow = self.lastPath != nil ? self.lastPath?.row:-1
        if (newRow != oldRow) {
            let newCell = tableView.cellForRow(at: indexPath)
            newCell?.accessoryType = UITableViewCellAccessoryType.checkmark
            let oldCell = tableView.cellForRow(at: self.lastPath!)
            oldCell?.accessoryType = UITableViewCellAccessoryType.none
            self .lastPath = indexPath
        }
         tableView.deselectRow(at: indexPath, animated: true)
         AppUserService.currentUser?.language =  NSNumber.init(value: Int64(indexPath.row))
         AppUserService.synchronizedCurrentUser()
         self.infoTableView.reloadData()
    }
}
