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
        loadData()
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
//        let tabbar = retrieveTabbarController()
//        tabbar?.setTabBarHidden(true, animated: true)
    }
    
    @objc func addUserBarButtonItemTap(_ sender:UIBarButtonItem){
        let addUserSettingViewController = DeviceAddUserSettingViewController.init(style:.highHeight)
        self.navigationController?.pushViewController(addUserSettingViewController, animated: true)
    }
    
    func prepareNavigation(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "add_user.png"), style: .plain, target: self, action: #selector(addUserBarButtonItemTap(_:)))
    }
    
    func loadData(){
        guard let stationId = AppUserService.currentUser?.stationId else {
            return
        }
        let requset =  StationUserAPI.init(stationId: stationId)
        requset.startRequestJSONCompletionHandler { [weak self] (response) in
            if let error =  response.error{
                Message.message(text: error.localizedDescription)
            }else{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                    return
                }
                if let rootDic = response.value as? NSDictionary {
                    if let dataDic = rootDic["data"] as? NSDictionary{
                         var array = Array<StationUserModel>.init()
                        do {
                            guard let data = jsonToData(jsonDic: dataDic) else{return}
                            let model = try JSONDecoder().decode(StationUserListModel.self, from: data)
                            if let owner = model.owner{
                               let ownerArray = owner.filter({$0.id != AppUserService.currentUser?.stationId})
                                array.append(contentsOf:ownerArray)
                            }
                            if let sharer = model.sharer{
                                let sharerArray = sharer.filter({$0.id != AppUserService.currentUser?.stationId})
                                array.append(contentsOf:sharerArray)
                            }
                            self?.dataSource = array
                            self?.infoSettingTableView.reloadData()
                        }catch{
                            print(error as Any)
                            //error
                        }
                    }
                }
            }
        }
    }
    
    lazy var infoSettingTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight), style: UITableViewStyle.plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib.init(nibName: StringExtension.classNameAsString(targetClass: DeviceUserManagerTableViewCell.self), bundle: nil), forCellReuseIdentifier: identifier)
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        return tableView
    }()
    
    lazy var dataSource = Array<StationUserModel>.init()
}

extension DeviceUsersManageViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DeviceUserManagerTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DeviceUserManagerTableViewCell
        let model = self.dataSource[indexPath.row]
        cell.titleLabel.text = model.username
//            cell.detailTextLabel?.text = "已用2.1GB"
//            cell.imageView?.layer.cornerRadius = cell.imageView?.width/2
        let placeholderImage = UIImage.init(named: "user_avatar_placeholder.png")
        if let avatarUrl = model.avatarUrl{
            cell.leftImageView.was_setCircleImage(withUrlString: avatarUrl, placeholder: placeholderImage)
        }else{
           cell.leftImageView.image = placeholderImage
        }
        cell.separatorInset = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 0)
       
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
        let userInfoViewController = DeviceUserInfoViewController.init(style: .highHeight)
        let navigationController = UINavigationController.init(rootViewController: userInfoViewController)
        self.present(navigationController, animated: true) {
            
        }
    }
}
