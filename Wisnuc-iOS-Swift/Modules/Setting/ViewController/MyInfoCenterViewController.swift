//
//  MyInfoCenterViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/11.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class MyInfoCenterViewController: BaseViewController {
    let identifier = "Cellidentifier"
    let headerHeight:CGFloat = 64
    let cellHeight:CGFloat = 64
    let avatarHeight:CGFloat = 40
    var wechatModels:[WechatInfoModel]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(infoTabelView)
        
        appBar.headerViewController.headerView.trackingScrollView = infoTabelView

        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        
        avatarImageView.layer.cornerRadius = avatarImageView.size.width/2
        
        avatarImageView.clipsToBounds = true
        
        AppUserService.updateCurrentUserInfo(complete: { [weak self] in
            self?.infoTabelView.reloadData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadWechatData { [weak self](models) in
            guard let wechatModels = models else{
                return
            }
            self?.wechatModels = wechatModels
            self?.infoTabelView.reloadData()
            
        }
        self.infoTabelView.reloadData()
    }
    
    func loadWechatData(closure:@escaping (_ wechatInfoModels:[WechatInfoModel]?)->()){
        ActivityIndicator.startActivityIndicatorAnimation()
        let requset = WechatInfoAPI.init()
        requset.startRequestJSONCompletionHandler({(response) in
            ActivityIndicator.stopActivityIndicatorAnimation()
            if let error =  response.error{
                Message.message(text: error.localizedDescription)
                return closure(nil)
            }else{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                    return closure(nil)
                }
                guard let rootDic = response.value as? NSDictionary else {
                    return closure(nil)
                }
                
                guard let dataArray = rootDic["data"] as? NSArray else {
                    return closure(nil)
                }
                var resultArray = Array<WechatInfoModel>.init()
                for value in dataArray{
                    if let dataDic = value as? NSDictionary{
                        do {
                            if let data = jsonToData(jsonDic: dataDic){
                                let model = try JSONDecoder().decode(WechatInfoModel.self, from: data)
                                resultArray.append(model)
                            }
                        }catch{
                            print(error as Any)
                        }
                    }
                }
                return closure(resultArray)
            }
        })
    }
    
    lazy var avatarImageView = UIImageView.init(frame: CGRect(x: __kWidth - MarginsCloseWidth - avatarHeight - MarginsWidth - MarginsSoFarWidth, y: cellHeight/2  - avatarHeight/2, width: avatarHeight, height: avatarHeight))

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

extension MyInfoCenterViewController:UITableViewDelegate{
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

extension MyInfoCenterViewController:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleLabel = UILabel.init(frame: CGRect(x: MarginsWidth, y: 0 , width: __kWidth - MarginsWidth*2, height: headerHeight))
        titleLabel.textColor = DarkGrayColor
        titleLabel.text = LocalizedString(forKey: "个人中心")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 21)
        headerView.addSubview(titleLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
//        if cell == nil {
        let  cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: identifier)
//        }
        switch indexPath.row {
            
        case 0:
            if let view = cell.contentView.subviews.first(where: {$0 is UIImageView}){
                view.removeFromSuperview()
            }
            cell.textLabel?.text = LocalizedString(forKey: "头像")
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            let image = UIImage.init(named: "avatar_placeholder.png")
            avatarImageView.was_setCircleImage(withUrlString: AppUserService.currentUser?.avaterURL ?? "", placeholder: image)
            cell.contentView.addSubview(avatarImageView)
        case 1:
            cell.textLabel?.text = LocalizedString(forKey: "昵称")
            cell.detailTextLabel?.text = LocalizedString(forKey: "去设置")
            if let nickName = AppUserService.currentUser?.nickName{
                cell.detailTextLabel?.text = nickName
            }
         
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        case 2:
            cell.textLabel?.text = LocalizedString(forKey: "账户名")
            if let userName = AppUserService.currentUser?.userName{
                if let placeUserName = userName.replacePhone(){
                    cell.detailTextLabel?.text = placeUserName
                }
            }
        case 3:
            cell.textLabel?.text = LocalizedString(forKey: "微信")
            var text = LocalizedString(forKey: "去绑定")
            if wechatModels != nil {
                 text = LocalizedString(forKey: "去更换")
            }
            cell.detailTextLabel?.text = text
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

