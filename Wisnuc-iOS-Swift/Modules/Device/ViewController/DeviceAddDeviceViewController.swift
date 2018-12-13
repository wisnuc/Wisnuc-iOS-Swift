//
//  DeviceAddDeviceViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/17.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceAddDeviceViewController: BaseViewController {
    let identifier = "celled"
    let cellHeight:CGFloat = 64
    let footerHeight:CGFloat = 48 + 28
    
    lazy var dataSource:Array<DeviceBLEModel> = [DeviceBLEModel]()
    lazy var dataPeripheralList:Array<CBPeripheral> = [CBPeripheral]()
    var selectModel:DeviceBLEModel?
    var state:SeekNewDeviceState?{
        didSet{
            switch state {
            case .searching?:
                searchingStateAction()
            case .notFound?:
                notFoundStateAction()
            case .found?:
                foundStateAction()
            case .bleNotOpen?:
                bleNotOpenAction()
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.largeTitle = LocalizedString(forKey: "Add Device")
        prepareNavigationBar()
        self.state = .searching
        self.view.addSubview(infoSettingTableView)
        self.view.bringSubview(toFront: appBar.appBarViewController.headerView)
      
        // Do any additional setup after loading the view.
    }
    
    deinit {
        LLBlueTooth.instance.disConnectPeripherals(dataPeripheralList)
        LLBlueTooth.instance.dispose()
            // Required for pre-iOS 11 devices because we've enabled observesTrackingScrollViewScrollEvents.
        appBar.appBarViewController.headerView.trackingScrollView = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.trackingScrollView = self.infoSettingTableView
        appBar.appBarViewController.headerView.observesTrackingScrollViewScrollEvents = true
        ViewTools.automaticallyAdjustsScrollView(scrollView: self.infoSettingTableView, viewController: self)
        LLBlueTooth.instance.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        LLBlueTooth.instance.stopScan()
    }
    
    func searchingStateAction(){
        self.largeTitle = LocalizedString(forKey: "搜索设备中...")
        let options =  [CBCentralManagerScanOptionAllowDuplicatesKey:false]
        LLBlueTooth.instance.scanForPeripheralsWithServices(nil, options: options as [String : AnyObject])
    }
    
    func notFoundStateAction(){
        self.largeTitle = LocalizedString(forKey: "未发现设备")
    }
    
    func foundStateAction(){
        self.largeTitle = LocalizedString(forKey: "发现设备")
        //        infoSettingTableView.removeAllSubviews()
    }
    
    func  bleNotOpenAction(){
        dataSource.removeAll()
        self.largeTitle = LocalizedString(forKey: "未发现设备")
        infoSettingTableView.reloadData()
        infoSettingTableView.addSubview(errorLabel)
        errorLabel.eventCallback = { () in
            if kCurrentSystemVersion <= 10.0 {
                UIApplication.shared.openURL(URL.init(string: "prefs:root=Bluetooth")!)
            }else {//prefs:root=Bluetooth
                let url = URL.init(string: "App-Prefs:root=General&path=Bluetooth")
                UIApplication.shared.openURL(url!)
            }
        }
    }
    
    @objc func dismiss(_ sender:UIBarButtonItem){
        self.presentingViewController?.dismiss(animated: true, completion: {
            
        })
    }
    
    @objc func confirmButtonTap(_ sender:UIButton){
        if let model = self.selectModel{
            switch model.type {
            case .NeedConfig?:
                let configNetVC = ConfigNetworkViewController.init(style: .whiteWithoutShadow,state:.add)
                configNetVC.deviceModel = model
                self.navigationController?.pushViewController(configNetVC, animated: true)
                LLBlueTooth.instance.stopScan()
                //        case .configFinish?:
            //           break
            case .Done?:
                Message.message(text: LocalizedString(forKey: "已被绑定，无法使用"))
            default:
                break
            }
        }
    }
    
    func nextButtonDisableStyle(){
        self.confirmButton.isEnabled = false
    }
    
    func nextButtonEnableStyle(){
        self.confirmButton.isEnabled = true
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
    
    lazy var confirmButton: UIButton = { [weak self] in
        let button = UIButton.init(frame: CGRect(x: MarginsWidth, y: 24, width:__kWidth - MarginsWidth*2 , height: 48))
        button.setTitle(LocalizedString(forKey: "确定"), for: UIControlState.normal)
        button.setTitleColor(.white, for: UIControlState.normal)
        button.setBackgroundImage(UIImage.init(color: COR1), for: UIControlState.normal)
        button.setBackgroundImage(UIImage.init(color: Gray12Color), for: UIControlState.disabled)
        button.layer.cornerRadius = 48/2
        button.clipsToBounds = true
        button.isEnabled = false
        button.addTarget(self, action: #selector(confirmButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        return button
        }()
    
    lazy var errorLabel:AttributeTouchLabel = {
        let string = "需要通过蓝牙发现设备\n蓝牙未打开，前往设置"
        let margin:CGFloat = 100
        let size = labelSizeToFit(title: LocalizedString(forKey: string), font: UIFont.systemFont(ofSize: 16))
        let label = AttributeTouchLabel.init(frame: CGRect(x: margin, y: __kHeight/2 - 50, width: __kWidth - margin*2, height: size.height + 4))
        label.content = string
        return label
    }()
}

extension DeviceAddDeviceViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView.init(frame: CGRect.zero)
        footerView.addSubview(confirmButton)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DeviceAddDeviceTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DeviceAddDeviceTableViewCell
        cell.selectionStyle = .none
        
        let model = dataSource[indexPath.row]
        cell.nameLabel.text = model.stationId
        cell.accessoryType = .none
        switch model.type {
        case .NeedConfig?:
            cell.detailLabel.text = LocalizedString(forKey: "待配置")
            cell.disabled = false
        case .Done?:
            cell.detailLabel.text = LocalizedString(forKey: "已配置")
            if let currentStationId = AppUserService.currentUser?.stationId,let stationId = model.stationId{
                if currentStationId.contains(stationId){
                    cell.detailLabel.text = LocalizedString(forKey: "当前连接")
                }
            }
       
            cell.disabled = true
        default:
            break
        }
//        switch indexPath.row {
//        case 0:
//            cell.nameLabel.text = LocalizedString(forKey: "Wisnuc Office")
//            cell.detailLabel.text = LocalizedString(forKey:"当前连接")
//            cell.disabled = false
//        case 1:
//            cell.nameLabel.text = LocalizedString(forKey: "Wisnuc-1")
//            cell.detailLabel.text = LocalizedString(forKey:"脱机")
//             cell.disabled = true
//        case 2:
//            cell.nameLabel.text = LocalizedString(forKey: "Wisnuc-2")
//            cell.detailLabel.text = LocalizedString(forKey:"在线")
//            cell.disabled = false
//        case 3:
//            cell.nameLabel.text = LocalizedString(forKey: "Wisnuc-3")
//            cell.detailLabel.text = LocalizedString(forKey:"关机")
//            cell.disabled = true
//            default:
//                break
//            }
//
//        if cell.isSelected {
//             cell.selectButton.isSelected = true
//        }
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
        let selectModel = dataSource[indexPath.row]
        self.selectModel = selectModel
        nextButtonEnableStyle()
        
    }
}

extension DeviceAddDeviceViewController:LLBlueToothDelegate{
    func peripheralCharacteristicDidUpdateValue(deviceBLEModels: [DeviceBLEModel]?) {
        if let devices = deviceBLEModels{
            dataSource = devices
            self.state = .found
            self.infoSettingTableView.reloadData()
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if(error != nil){
            return
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
    }
    
    func didDiscoverPeripheral(_ peripheral: CBPeripheral) {
        //  在这个地方可以判读是不是自己本公司的设备,这个是根据设备的名称过滤的
        guard peripheral.name != nil , peripheral.name!.contains("Wisnuc") else {
            return
        }
        
        if !(dataPeripheralList.contains(peripheral)) {
            dataPeripheralList.append(peripheral)
            LLBlueTooth.instance.requestConnectPeripheral(peripheral)
        }
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if #available(iOS 10.0, *) {
            switch central.state {
                
            case CBManagerState.poweredOn:
                print("蓝牙打开")
                self.state = .searching
                
            case CBManagerState.unauthorized:
                print("没有蓝牙功能")
                
            case CBManagerState.poweredOff:
                print("蓝牙关闭")
                self.state = .bleNotOpen
                
            default:
                print("未知状态")
            }
        }
    }
}

