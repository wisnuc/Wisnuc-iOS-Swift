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
    lazy var dataSource:[StationsInfoModel] = Array.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStations()
        prepareNavigationBar()
        self.view.addSubview(deviveTabelView)
        appBar.headerViewController.headerView.trackingScrollView = deviveTabelView
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
    }

    func prepareNavigationBar(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "close_gray.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(dismiss(_ :)))
    }
    
    func loadStations() {
        if let token = AppUserService.currentUser?.cloudToken {
            LoginCommonHelper.instance.getStations(token: token) { [weak self](error, stations) in
                if error != nil{
                    switch error {
                    case is BaseError:
                        let baseError = error as! BaseError
                        Message.message(text: baseError.localizedDescription)
                    case is LoginError:
                        let loginError = error as! LoginError
                        Message.message(text: loginError.localizedDescription)
                    default:
                        Message.message(text: (error?.localizedDescription)!)
                    }
                }else{
                    if let stations = stations{
                        self?.dataSource = stations
                        self?.deviveTabelView.reloadData()
                        self?.fetchDeviceSpace(stations: stations)
                    }
                }
            }
        }
    }
    
    func fetchDeviceSpace(stations:[StationsInfoModel]){
        var changeStations = stations
        for (i,value) in stations.enumerated() {
            if let stationId = value.sn,let addr = value.LANIP{
                let request = BootSpaceAPI.init(stationId: stationId, address: addr)
                request.startRequestJSONCompletionHandler { [weak self](response) in
                    if let error = response.error {
                        Message.message(text: error.localizedDescription)
                    }else{
                        if let errorMessage = ErrorTools.responseErrorData(response.data){
                            Message.message(text: errorMessage)
                        }else{
                            if let rootDic = response.value as? NSDictionary {
                                let  isLocal = AppNetworkService.networkState == .local ? true : false
                                var dataDic = rootDic
                                if !isLocal{
                                    if let dic = rootDic["data"] as? NSDictionary{
                                        dataDic = dic
                                    }
                                }
                                do {
                                    guard let data = jsonToData(jsonDic: dataDic) else{
                                        return
                                    }
                                    let spaceModel = try JSONDecoder().decode(BootSpaceModel.self, from: data)
                                    var stationInfoModel = changeStations[i]
                                    stationInfoModel.bootSpace = spaceModel
                                    self?.dataSource[i] = stationInfoModel
                                    self?.deviveTabelView.reloadData()
                                }catch{
                                    print(error as Any)
                                    //error
                                }
                            }
                        }
                    }
                }
            }
        }
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
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        return tableView
        }()
}

extension DeviceChangeDeviceViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let stationInfoModel = dataSource[indexPath.row]
        if stationInfoModel.sn == AppUserService.currentUser?.stationId{ return }
        
        guard let online =  stationInfoModel.online else { return }
        
        if online == 0 {return}
        
        switch indexPath.row {
        case 0:
            break
        case 1:
            //初始化提示框
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            //按钮：从相册选择，类型：UIAlertActionStyleDefault
            alert.addAction(UIAlertAction(title: LocalizedString(forKey: "切换到当前设备") , style: .default, handler: { action in
                self.presentingViewController?.dismiss(animated: true, completion: {
                    AppService.sharedInstance().loginAction(stationModel: stationInfoModel, orginTokenUser: AppUserService.currentUser!, complete: { (error, user) in
                        if  error == nil &&  user != nil{
                            AppUserService.isUserLogin = true
                            AppUserService.isStationSelected = true
                            AppUserService.setCurrentUser(user)
                            AppUserService.currentUser?.isSelectStation = NSNumber.init(value: AppUserService.isStationSelected)
                            AppUserService.synchronizedCurrentUser()
                            appDelegate.initRootVC()
                        }
                    })
                })
            }))
            alert.addAction(UIAlertAction(title:  LocalizedString(forKey: "取消"), style: .cancel, handler: nil))
            present(alert, animated: true)
        default: break
            
        }
    }
}

extension DeviceChangeDeviceViewController:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DeviceChangeDeviceTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DeviceChangeDeviceTableViewCell
        tableView.separatorStyle = .none
        cell.selectionStyle = .none
        let stationInfoModel = dataSource[indexPath.row]
        cell.titleLabel.text = stationInfoModel.name
        if let total = stationInfoModel.bootSpace?.total ,let used = stationInfoModel.bootSpace?.used{
            cell.capacityLabel.text =  "\(sizeString(used*1024)) / \(sizeString(total*1024))"
            cell.capacityProgressView.progress =  Float(used)/Float(total)
        }else{
            cell.capacityLabel.text =  LocalizedString(forKey: "Loading...")
        }
        cell.isDisable = true
        if stationInfoModel.sn == AppUserService.currentUser?.stationId{
            cell.isCurrentDevice = true
        }else{
            cell.isCurrentDevice = true
        }
        
        if let online = stationInfoModel.online{
            if online == 1{
              cell.isDisable = false
            }
        }
        return cell
    }
}
