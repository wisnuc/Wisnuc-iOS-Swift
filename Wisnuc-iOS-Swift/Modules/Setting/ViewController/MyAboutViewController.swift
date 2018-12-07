//
//  MyAboutViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/11.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class MyAboutViewController: BaseViewController {
    let identifier = "celled"
    override func viewDidLoad() {
        super.viewDidLoad()
        setContentFrame()
        self.view.addSubview(titleLabel)
        self.view.addSubview(detailLabel)
        self.view.addSubview(logoImageView)
        self.view.addSubview(infoTabelView)
    
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        // Do any additional setup after loading the view.
    }
    
    func setContentFrame(){
        titleLabel.frame = CGRect(x: MarginsWidth, y: MarginsWidth + MDCAppNavigationBarHeight , width: __kWidth - MarginsWidth*2, height: 48)
        detailLabel.frame = CGRect(x: MarginsWidth, y: logoImageView.bottom + MarginsWidth , width: __kWidth - MarginsWidth*2, height: 38)
        
        logoImageView.image = UIImage.init(named: "logo_main_theme.png")
        
    }
    
    @objc func agreementBttonTap(_ sender:UIButton){
        let agreementVC = MyUserAgreementViewController.init(style: NavigationStyle.mainTheme)
        let navi = UINavigationController.init(rootViewController: agreementVC)
        self.present(navi, animated: true) {
            
        }
    }
    
    lazy var titleLabel = UILabel.initTitleLabel(color: DarkGrayColor, text: LocalizedString(forKey: "关于_闻上云盘"))
    lazy var detailLabel = UILabel.initDetailTitleLabel(text:LocalizedString(forKey: "多设备，跨平台，让您随时随地，\n 方便快捷地管理您的数据"))

    lazy var logoImageView = UIImageView.init(frame: CGRect(x: MarginsWidth, y: titleLabel.bottom + 44, width: 72, height: 72))
    lazy var infoTabelView: UITableView = { [weak self] in
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: (self?.detailLabel.bottom)! + 32, width: __kWidth, height: __kHeight), style: UITableViewStyle.plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.backgroundColor = .white
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    lazy var agreementBtton: UIButton = {
        let text = "用户使用协议"
        let font = UIFont.systemFont(ofSize: 16)
        let width = labelWidthFrom(title: text, font: font)
        let button = UIButton.init(frame: CGRect(x: MarginsWidth, y: 40 - 16, width: width, height: 16))
        button.setTitle(text, for: UIControlState.normal)
        button.setTitleColor(COR1, for: UIControlState.normal)
        button.titleLabel?.font = font
        button.addTarget(self, action: #selector(agreementBttonTap(_ :)), for: UIControlEvents.touchUpInside)
        return button
    }()
}

extension MyAboutViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let urlStr = "https://itunes.apple.com/cn/app/id\(kAppId)"
            if let aString = URL(string: urlStr) {
                UIApplication.shared.openURL(aString)
            }
        default: break
            
        }
    }
}

extension MyAboutViewController:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.zero)
        let lineView = UIView.init(frame: CGRect(x: MarginsWidth, y: 0.1, width: __kWidth - MarginsWidth*2, height: 1))
        lineView.backgroundColor = Gray8Color
        view.addSubview(lineView)
        view.addSubview(agreementBtton)
        return view
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        //        if cell == nil {
        let  cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: identifier)
        //        }
        switch indexPath.row {
            
        case 0:
            cell.textLabel?.text = LocalizedString(forKey: "升级")
            cell.detailTextLabel?.text = "\(LocalizedString(forKey: "当前版本"))V\(kCurrentAppVersion)"
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
      
        default: break
            
        }
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        cell.textLabel?.textColor = DarkGrayColor
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.textColor = LightGrayColor
        return cell
    }
    
}
