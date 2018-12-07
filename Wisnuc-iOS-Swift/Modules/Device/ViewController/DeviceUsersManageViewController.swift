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
//        let tabbar = retrieveTabbarController()
//        tabbar?.setTabBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
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
        let requset =  StationUserAPI.init(stationId: stationId, type: .fetchInfo)
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
                               let ownerArray = owner.filter({$0.id != AppUserService.currentUser?.uuid})
                                array.append(contentsOf:ownerArray)
                            }
                            if let sharer = model.sharer{
                                let sharerArray = sharer.filter({$0.id != AppUserService.currentUser?.uuid})
                                array.append(contentsOf:sharerArray)
                            }
                            self?.dataSource = array
                            self?.infoSettingTableView.reloadData()
//                            self?.fetchDeviceSpace(stations: array)
                        }catch{
                            print(error as Any)
                            //error
                        }
                    }
                }
            }
        }
    }
    
//    func fetchDeviceSpace(stations:[StationUserModel]){
//        var changeStations = stations
//        for (i,value) in stations.enumerated() {
//            if let stationId = value.id{
//                let request = BootSpaceAPI.init(stationId: stationId)
//                request.startRequestJSONCompletionHandler { [weak self](response) in
//                    if let error = response.error {
//                        Message.message(text: error.localizedDescription)
//                    }else{
//                        if let errorMessage = ErrorTools.responseErrorData(response.data){
//                            Message.message(text: errorMessage)
//                        }else{
//                            if let rootDic = response.value as? NSDictionary {
//                                if let dic = rootDic["data"] as? NSDictionary{
//                                    do {
//                                        guard let data = jsonToData(jsonDic: dic) else{
//                                            return
//                                        }
//                                        let spaceModel = try JSONDecoder().decode(BootSpaceModel.self, from: data)
//                                        var stationUserModel = changeStations[i]
//                                        stationUserModel.bootSpace = spaceModel
//                                        self?.dataSource[i] = stationUserModel
//                                        self?.infoSettingTableView.reloadData()
//                                    }catch{
//                                        print(error as Any)
//                                        //error
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
    func deleteSharedUser(model:StationUserModel?){
        guard let stationId = AppUserService.currentUser?.stationId else { return }
        guard let userId = model?.id else { return }
        let requset = StationUserAPI.init(stationId: stationId, type: .delete, userId: userId)
        requset.startRequestJSONCompletionHandler { (response) in
            ActivityIndicator.stopActivityIndicatorAnimation()
            if let error =  response.error{
                Message.message(text: error.localizedDescription)
            }else{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                    return
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
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
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
//        if let used = model.bootSpace?.used{
//            cell.detailLabel.text = "\(sizeString(used*1024))"
//        }else{
//            cell.detailLabel.text = LocalizedString(forKey: "Loading...")
//        }
        
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
           let index = indexForAction.row
            self?.alertController(title: LocalizedString(forKey:"您确定删除该用户吗？"), cancelActionTitle: LocalizedString(forKey: "Cancel"), okActionTitle: LocalizedString(forKey: "Confirm"), okActionHandler: { (okAlertAction) in
                let model = self?.dataSource[indexPath.row]
                self?.deleteSharedUser(model: model)
                self?.dataSource.remove(at: index)
                
                tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }, cancelActionHandler: { (cancelAlertAction) in
                
            })
//            let index = indexForAction.row
//            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        deleteRowAction.backgroundColor = UIColor.red

        return [deleteRowAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = self.dataSource[indexPath.row]
        let userInfoViewController = DeviceUserInfoViewController.init(style: .highHeight,stationUserModel:model)
        let navigationController = UINavigationController.init(rootViewController: userInfoViewController)
        self.present(navigationController, animated: true) {
            
        }
    }
}

extension DeviceUsersManageViewController:DZNEmptyDataSetSource{
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage.init(named: "logo_gray")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = LocalizedString(forKey: "暂无用户")
        let attributes = [NSAttributedStringKey.font : MiddleTitleFont,NSAttributedStringKey.foregroundColor : LightGrayColor]
        return NSAttributedString.init(string: text, attributes: attributes)
    }
    
}

extension DeviceUsersManageViewController:DZNEmptyDataSetDelegate{
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        //        self.prepareData()
    }
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView!) -> Bool {
        if self.dataSource.count == 0{
            return true
        }else{
            return false
        }
    }
}
