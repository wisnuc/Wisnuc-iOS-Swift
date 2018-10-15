//
//  MySecureStepViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/15.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class MySecureStepViewController: BaseViewController {
    let headerHeight:CGFloat = 48
    let cellHeight:CGFloat = 72
    let identifier = "celled"
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(infoTabelView)
        
        appBar.headerViewController.headerView.trackingScrollView = infoTabelView
        
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
    }
    
    lazy var infoTabelView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight), style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.tableFooterView = UIView.init()
        tableView.backgroundColor = .white
        tableView.isScrollEnabled = false
        return tableView
    }()

}

extension MySecureStepViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let avatarChangeVC = AvatarChangeViewController.init(style: .black)
            self.navigationController?.pushViewController(avatarChangeVC, animated: true)
        case 1:
            let nicknameVC = MyNicknameChangeViewController.init(style: .whiteWithoutShadow)
            self.navigationController?.pushViewController(nicknameVC, animated: true)
        case 2:
            break
        case 3:
            let bindWechatVC = MyBindWechatViewController.init(style: .whiteWithoutShadow)
            self.navigationController?.pushViewController(bindWechatVC, animated: true)
        default: break
            
        }
    }
}

extension MySecureStepViewController:UITableViewDataSource{
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
        if section == 0 {
            let headerView = UIView.init(frame: CGRect.zero)
            let titleLabel = UILabel.init(frame: CGRect(x: MarginsWidth, y: 0 , width: __kWidth - MarginsWidth*2, height: headerHeight))
            titleLabel.textColor = DarkGrayColor
            titleLabel.text = LocalizedString(forKey: "剩余步骤")
            titleLabel.font = UIFont.boldSystemFont(ofSize: 21)
            headerView.addSubview(titleLabel)
            return headerView
        }else{
            let headerView = UIView.init(frame: CGRect.zero)
            let titleLabel = UILabel.init(frame: CGRect(x: MarginsWidth, y: 0 , width: __kWidth - MarginsWidth*2, height: headerHeight))
            titleLabel.textColor = DarkGrayColor
            titleLabel.text = LocalizedString(forKey: "已完成")
            titleLabel.font = UIFont.boldSystemFont(ofSize: 21)
            headerView.addSubview(titleLabel)
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if indexPath.section == 0{
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = LocalizedString(forKey: "绑定邮箱")
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            default: break
                
            }
          
        }else{
            switch indexPath.row {
            case 0:
            cell.textLabel?.text = LocalizedString(forKey: "绑定手机")
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            default: break
                
            }
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.textLabel?.textColor = DarkGrayColor
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.textColor = LightGrayColor
        return cell
    }
    
}
