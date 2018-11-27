//
//  DeviceNetworkSettingViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/17.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

enum DeviceNetworkSpeedTestState {
    case ready
    case testing
    case finish
}

class DeviceNetworkSettingViewController: BaseViewController {
    let identifier = "celled"
    let cellHeight:CGFloat = 64
    lazy var modelDataSource:Array<DeviceNetModel>? = Array.init()
    var state:DeviceNetworkSpeedTestState?{
        didSet{
          infoSettingTableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        self.largeTitle = LocalizedString(forKey: "网络")
        self.state = .ready
        prepareNavigation()
        self.view.addSubview(infoSettingTableView)
        self.view.bringSubview(toFront: appBar.appBarViewController.headerView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.trackingScrollView = self.infoSettingTableView
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = true
        ViewTools.automaticallyAdjustsScrollView(scrollView: self.infoSettingTableView, viewController: self)
        let tab = retrieveTabbarController()
        tab?.setTabBarHidden(true, animated: true)
    }
    
    func loadData(){
        let requset = DeviceNetAPI.init()
        requset.startRequestJSONCompletionHandler { [weak self](response) in
            if let error =  response.error{
                Message.message(text: error.localizedDescription)
            }else{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                    return
                }
                
                let  isLocal = AppNetworkService.networkState == .local ? true : false
                var rootArray = NSArray.init()
                if response.value is NSArray {
                    rootArray = response.value as! NSArray
                }
                if !isLocal && response.value is NSDictionary{
                    let rootDic = response.value as! NSDictionary
                    if let array = rootDic["data"] as? NSArray{
                        rootArray = array
                    }
                }
                var resultArray = Array<DeviceNetModel>.init()
                for dataDic in rootArray{
                    if let dataDic = dataDic as? NSDictionary{
                        guard let data = jsonToData(jsonDic: dataDic) else{
                            return
                        }
                        do {
                            let model = try JSONDecoder().decode(DeviceNetModel.self, from: data)
                            resultArray.append(model)
                        }catch{
                            print(error as Any)
                            //error
                        }
                    }
                }
                self?.modelDataSource = resultArray
                self?.infoSettingTableView.reloadData()
            }
        }
    }
    
    @objc func rightBarButtonItemTap(_ sender:UIBarButtonItem){
        let configNetVC = ConfigNetworkViewController.init(style: .whiteWithoutShadow ,state:.change )
        self.navigationController?.pushViewController(configNetVC, animated: true)
    }
    
    func prepareNavigation(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: LocalizedString(forKey:"切换Wi-Fi"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightBarButtonItemTap(_:)))
    }
    
    lazy var infoSettingTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight), style: UITableViewStyle.plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        return tableView
    }()
    
    lazy var speedActivityIndicator: MDCActivityIndicator = {
        let width: CGFloat = __kWidth
        let height: CGFloat = cellHeight/2
        //Initialize single color progress indicator
        let frame: CGRect = CGRect(x: width - MarginsWidth -  20, y: height - 20/2, width: 20, height: 20)
        let activityIndicator = MDCActivityIndicator(frame: CGRect.zero)
        activityIndicator.frame = frame
        // Pass colors you want to indicator to cycle through
        activityIndicator.cycleColors = [COR1]
        activityIndicator.radius = 10.0
        activityIndicator.strokeWidth = 2.0
        activityIndicator.indicatorMode = .indeterminate
//        activityIndicator.sizeToFit()
        return activityIndicator
    }()
}

extension DeviceNetworkSettingViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: identifier)
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = LocalizedString(forKey: "当前网络")
            cell.detailTextLabel?.text = "naxian800"
        case 1:
            cell.textLabel?.text = LocalizedString(forKey:"IP地址")
            cell.detailTextLabel?.text = LocalizedString(forKey: "Loading...")
            if (modelDataSource?.count)! > 0{
                if let model = modelDataSource?.first(where: {$0.state == "up"}){
                    if let detailModel =  model.ipAddresses?.first(where: {$0.family == "IPv4"}){
                        cell.detailTextLabel?.text = detailModel.address
                    }
                }
            }
        case 2:
            cell.textLabel?.text = LocalizedString(forKey:"测速")
            let label = UILabel.init(frame: CGRect(x: __kWidth - (__kWidth/2 - 50) - speedActivityIndicator.width - 10 - MarginsWidth, y: 0, width: __kWidth/2 - 50, height: cellHeight))
            label.textColor = LightGrayColor
            label.textAlignment = .right
            label.font = UIFont.systemFont(ofSize: 14)
            label.text = LocalizedString(forKey: "测速中...")
            switch self.state {
            case .ready?:
                cell.detailTextLabel?.text = "点击测试"
            case .testing?:
                speedActivityIndicator.startAnimating()
                cell.contentView.addSubview(speedActivityIndicator)
                cell.contentView.addSubview(label)
            case .finish?:
                speedActivityIndicator.stopAnimating()
                speedActivityIndicator.removeFromSuperview()
                label.removeFromSuperview()
                cell.detailTextLabel?.text = "1M/S"
            default:
                break
            }
           
        default:
            break
        }
    
        cell.textLabel?.textColor = DarkGrayColor
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cell.detailTextLabel?.textColor = LightGrayColor
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    
        switch indexPath.row {
        case 2:
            self.state = .testing
            DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 3) {
                    DispatchQueue.main.async {
                     self.state = .finish
                }
            }
        default:
            break
        }
      
    }
}
