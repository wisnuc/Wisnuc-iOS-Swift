//
//  MyAccountSecurityViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/11.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Material

class MyAccountSecurityViewController: BaseViewController {
    let identifier = "Cellidentifier"
    let headerHeight:CGFloat = 48
    let cellHeight:CGFloat = 72
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(infoTabelView)
        
        appBar.headerViewController.headerView.trackingScrollView = infoTabelView
        
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
    }
    
    func rightLabel(_ text:String) ->UILabel{
        let rightFont = UIFont.systemFont(ofSize: 14)
        let rightText = text
        let height:CGFloat = 14
        let width:CGFloat = labelWidthFrom(title: rightText, font: rightFont)
        
        let label = UILabel.init(frame: CGRect(x: __kWidth - MarginsCloseWidth - width - MarginsWidth - MarginsWidth, y: cellHeight/2  - height/2, width: width, height: height))
        label.font = rightFont
        label.textColor = LightGrayColor
        label.text = rightText
        label.textAlignment = .right
        
        return label
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == infoTabelView {
//            var tableview = scrollView as? UITableView
            let sectionHeaderHeight: CGFloat = headerHeight
            if scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0 {
                scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0)
            } else if scrollView.contentOffset.y >= sectionHeaderHeight {
                scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0)
            }
        }
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
    
    lazy var headerView: UIView = {
        let view = UIView.init(frame: CGRect.zero)
        //        view.backgroundColor = .red
        return view
    }()
}

extension MyAccountSecurityViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0{
            switch indexPath.row {
            case 0:
                break
            case 1:
                break
            case 2:
                let bindPhoneViewController = MyBindPhoneViewController.init(style: .whiteWithoutShadow)
                self.navigationController?.pushViewController(bindPhoneViewController, animated: true)
            case 3:
                let verificationCodeVC = MyVerificationCodeViewController.init(style: .whiteWithoutShadow,state:.phone,nextState:.bindEmail)
                self.navigationController?.pushViewController(verificationCodeVC, animated: true)
            default: break
                
            }
        }else{
            
        }
       
    }
}

extension MyAccountSecurityViewController:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 4
        }else{
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
            let titleLabel = UILabel.init(frame: CGRect(x: MarginsWidth, y: 0 , width: __kWidth - MarginsWidth*2, height: headerHeight))
            titleLabel.textColor = DarkGrayColor
            titleLabel.text = LocalizedString(forKey: "账户安全")
            titleLabel.font = UIFont.boldSystemFont(ofSize: 21)
            headerView.addSubview(titleLabel)
            return headerView
        }else{
            let separateView = UILabel.init(frame: CGRect(x: 0, y: 0 , width: __kWidth, height: MarginsCloseWidth))
            separateView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x0f5f5f5)
            let titleLabel = UILabel.init(frame: CGRect(x: MarginsWidth, y: separateView.height , width: __kWidth - MarginsWidth*2, height: headerHeight - separateView.height))
            titleLabel.textColor = LightGrayColor
            titleLabel.text = LocalizedString(forKey: "安全性高级设置")
            titleLabel.font = UIFont.systemFont(ofSize: 14)
            let headerView = UIView.init(frame: CGRect.zero)
            headerView.addSubview(separateView)
            headerView.addSubview(titleLabel)
            return headerView
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: identifier)
        if indexPath.section == 0{
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = LocalizedString(forKey: "账号")
                cell.detailTextLabel?.text = LocalizedString(forKey: "139****7773")
                
            case 1:
                cell.textLabel?.text = LocalizedString(forKey: "密码")
                let secureLevelString = "低"
                let detailText = "安全性 \(secureLevelString)"
                let attributedText = NSMutableAttributedString.init(string:detailText )
                let font = UIFont.systemFont(ofSize: 12)
                attributedText.addAttribute(NSAttributedStringKey.font, value:font , range: NSRange.init(location: 0, length: attributedText.length))
                attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: LightGrayColor, range: NSRange.init(location: 0, length: 3))
                attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange.init(location: 4, length: 1))
                cell.detailTextLabel?.attributedText = attributedText
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                
                let label = self.rightLabel(LocalizedString(forKey: "去修改"))
                cell.contentView.addSubview(label)
            case 2:
                cell.textLabel?.text = LocalizedString(forKey: "绑定手机号")
                cell.detailTextLabel?.text = LocalizedString(forKey: "139****7773")
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                
                let label = self.rightLabel(LocalizedString(forKey: "去修改"))
                cell.contentView.addSubview(label)
            case 3:
                cell.textLabel?.text = LocalizedString(forKey: "邮箱")
                cell.detailTextLabel?.text = LocalizedString(forKey: "未绑定")
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                
                let label = self.rightLabel(LocalizedString(forKey: "去绑定"))
                cell.contentView.addSubview(label)
            default: break
                
            }
        }else{
            let radioButtonHeight:CGFloat = 20
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = LocalizedString(forKey: "仅通过绑定手机找回密码")
                let button = UIButton.init(frame: CGRect(x: __kWidth - radioButtonHeight - MarginsWidth, y: cellHeight/2  - radioButtonHeight/2, width: radioButtonHeight, height: radioButtonHeight))
                button.setImage(UIImage.init(named: "radioButton_right.png"), for: UIControlState.normal)
                cell.contentView.addSubview(button)
            case 1:
               cell.textLabel?.text = LocalizedString(forKey: "仅使用邮箱找回密码")
            case 2:
                cell.textLabel?.text = LocalizedString(forKey: "双重身份验证")
            default: break
                
            }
        }
    
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.textLabel?.textColor = DarkGrayColor
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        cell.detailTextLabel?.textColor = LightGrayColor
        return cell
    }
    
}
