//
//  SeekNewDeviceViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/13.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import CoreBluetooth
enum SeekNewDeviceState {
    case found
    case notFound
    case bleNotOpen
    case searching
}
class SeekNewDeviceViewController: BaseViewController {
    let cellReuseIdentifier = "cell"
    lazy var dataSource:Array<DeviceBLEModel> = [DeviceBLEModel]()
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
         self.deviceTableView.register(UINib.init(nibName: StringExtension.classNameAsString(targetClass: SeekNewDeviceTableViewCell.self), bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        self.view.addSubview(titleLabel)
        self.view.addSubview(deviceTableView)
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.trackingScrollView = self.deviceTableView
        LLBlueTooth.instance.delegate = self
    }
    
    func searchingStateAction(){
        titleLabel.text = LocalizedString(forKey: "未发现设备")
    }
    
    func notFoundStateAction(){
       titleLabel.text = LocalizedString(forKey: "未发现设备")
    }
    
    func foundStateAction(){
        titleLabel.text = LocalizedString(forKey: "发现设备")
        deviceTableView.removeAllSubviews()
    }
    
    func  bleNotOpenAction(){
        dataSource.removeAll()
        titleLabel.text = LocalizedString(forKey: "未发现设备")
        deviceTableView.reloadData()
        deviceTableView.addSubview(errorLabel)
        errorLabel.eventCallback = { () in
            if kCurrentSystemVersion <= 10.0 {
                UIApplication.shared.openURL(URL.init(string: "prefs:root=Bluetooth")!)
            }else {//prefs:root=Bluetooth
                let url = URL.init(string: "App-Prefs:root=General&path=Bluetooth")
                UIApplication.shared.openURL(url!)
            }
        }
    }
    
    func setData(){
        let data1 = DeviceBLEModel.init(name: "Device1", type: DeviceBLEModelType.configFinish)
        let data2 = DeviceBLEModel.init(name: "不知道什么名字的设备", type: DeviceBLEModelType.configWithData)
        let data3 = DeviceBLEModel.init(name: "新新新设备", type: DeviceBLEModelType.config)
        let data4 = DeviceBLEModel.init(name: "Error Device", type: DeviceBLEModelType.configErrorNoDisk)
        dataSource.append(data1)
        dataSource.append(data2)
        dataSource.append(data3)
        dataSource.append(data4)
        deviceTableView.reloadData()
        self.state = .found
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: 64/2 - 22/2, width: __kWidth - MarginsWidth*2, height: 22))
        label.font = UIFont.boldSystemFont(ofSize: 21)
        label.textColor = DarkGrayColor
        return label
    }()
    
    lazy var deviceTableView: UITableView = { [weak self] in
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight), style: UITableViewStyle.grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        return tableView
    }()
    
    lazy var errorLabel:AttributeTouchLabel = {
        let string = "需要通过蓝牙发现设备 蓝牙未打开，前往设置"
        let margin:CGFloat = 100
        let size = labelSizeToFit(title: LocalizedString(forKey: string), font: UIFont.systemFont(ofSize: 16))
        let label = AttributeTouchLabel.init(frame: CGRect(x: margin, y: __kHeight/2 - 50, width: __kWidth - margin*2, height: size.height + 4))
        label.content = string
        return label
    }()
}

extension SeekNewDeviceViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorStyle = .none
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! SeekNewDeviceTableViewCell
        let model = dataSource[indexPath.row]
        cell.titleLabel.text = model.name
        cell.accessoryType = .none
        switch model.type {
        case .config?:
            cell.detailLabel.text = LocalizedString(forKey: "待配置")
            cell.rightImageView.image =  UIImage.init(named: "disclosureIndicator.png")
        case .configFinish?:
            cell.detailLabel.text = LocalizedString(forKey: "已配置")
            cell.rightImageView.image =  UIImage.init(named: "config_finish.png")
        case .configWithData?:
            cell.detailLabel.text = LocalizedString(forKey: "待配置，磁盘含有数据")
            cell.rightImageView.image =  UIImage.init(named: "disclosureIndicator.png")
        case .configErrorNoDisk?:
            cell.detailLabel.text = LocalizedString(forKey: "检测不到设备磁盘")
            cell.rightImageView.image =  UIImage.init(named: "config_error.png")
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.row]
        switch model.type {
        case .config?:
            break
        case .configFinish?:
            let configNetVC = ConfigNetworkViewController.init(style: .whiteWithoutShadow)
            self.navigationController?.pushViewController(configNetVC, animated: true)
        case .configWithData?:
            break
        case .configErrorNoDisk?:
            break
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init()
        headerView.addSubview(self.titleLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }
}

extension SeekNewDeviceViewController:LLBlueToothDelegate{
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
    }
    
    func didDiscoverPeripheral(_ peripheral: CBPeripheral) {
      
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if #available(iOS 10.0, *) {
            switch central.state {
                
            case CBManagerState.poweredOn:
                print("蓝牙打开")
                self.state = .searching
                self.setData()
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
