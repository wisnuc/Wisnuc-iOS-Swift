//
//  LLBlueTooth.swift
//  BluetoothBLEDemo
//
//  Created by wisnuc-imac on 2018/8/22.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

import Foundation
import CoreBluetooth


let kDataCharacteristic = "F000C0E1-0451-4000-B000-000000000000"
@objc protocol LLBlueToothDelegate {
    func didDiscoverPeripheral(_ peripheral:CBPeripheral)
  @objc optional  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
     func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
     func centralManagerDidUpdateState(_ central: CBCentralManager)
}


//用于看发送数据是否成功!
class LLBlueTooth:NSObject {
    
    weak var delegate:LLBlueToothDelegate?
    
    //单例对象
    internal static let instance = LLBlueTooth()
    
    //中心对象
    var central : CBCentralManager?
    
    //中心扫描到的设备都可以保存起来，
    //扫描到新设备后可以通过通知的方式发送出去，连接设备界面可以接收通知，实时刷新设备列表
    var deviceList: NSMutableArray?{
        didSet{
            
        }
    }
    
    // 当前连接的设备
    var peripheral:CBPeripheral!
    
    //发送数据特征(连接到设备之后可以把需要用到的特征保存起来，方便使用)
    var sendCharacteristic:CBCharacteristic?
    
    
    override init() {
        
        super.init()
        
        self.central = CBCentralManager.init(delegate:self, queue:nil, options:[CBCentralManagerOptionShowPowerAlertKey:false])
        
        self.deviceList = NSMutableArray()
        
    }
    
    
    // MARK: 扫描设备的方法
    func scanForPeripheralsWithServices(_ serviceUUIDS:[CBUUID]?, options:[String: AnyObject]?){
        
        self.central?.scanForPeripherals(withServices: serviceUUIDS, options: options)
        
    }
    
    
    // MARK: 停止扫描
    func stopScan() {
        
        self.central?.stopScan()
        
    }
    
    // MARK: 写数据
    func writeToPeripheral(_ data: Data) {
        peripheral.writeValue(data , for: sendCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
    }
    
    
    // MARK: 连接某个设备的方法
    /*
     *  设备有几个状态
     @available(iOS 7.0, *)
     public enum CBPeripheralState : Int {
     case disconnected
     
     case connecting
     
     case connected
     
     @available(iOS 9.0, *)
     case disconnecting
     }
     */
    func requestConnectPeripheral(_ model:CBPeripheral) {
        
        if (model.state != CBPeripheralState.connected) {
            
            central?.connect(model , options: nil)
            
        }
        
    }
    
}


//MARK: -- 中心管理器的代理
extension LLBlueTooth : CBCentralManagerDelegate{
    
    // MARK: 检查运行这个App的设备是不是支持BLE。
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        
        if #available(iOS 10.0, *) {
            switch central.state {
                
            case CBManagerState.poweredOn:
                print("蓝牙打开")
                
            case CBManagerState.unauthorized:
                print("没有蓝牙功能")
                
            case CBManagerState.poweredOff:
                print("蓝牙关闭")
                
            default:
                print("未知状态")
            }
        }
        // 手机蓝牙状态发生变化，可以发送通知出去。提示用户
        
        self.delegate?.centralManagerDidUpdateState(central)
    }
    
    
    // 开始扫描之后会扫描到蓝牙设备，扫描到之后走到这个代理方法
    // MARK: 中心管理器扫描到了设备
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral.name ?? "No name")
//        peripheral.
        //  在这个地方可以判读是不是自己本公司的设备,这个是根据设备的名称过滤的
//        guard peripheral.name != nil , peripheral.name!.contains("*****") else {
//            return
//        }
        if !(deviceList?.contains(peripheral))! {
            deviceList?.add(peripheral)
        }
        
    
        if let delegateOK = self.delegate{
            delegateOK.didDiscoverPeripheral(peripheral)
        }
        
        //  这里判断重复，加到devielist中。发出通知。
        
    }
    

    // MARK: 连接外设成功，开始发现服务
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral){
        
        // 设置代理
        peripheral.delegate = self
        
        // 开始发现服务
        peripheral.discoverServices(nil)
        
        // 保存当前连接设备
        self.peripheral = peripheral
        
        // 这里可以发通知出去告诉设备连接界面连接成功
        
    }
    
    // MARK: 连接外设失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        // 这里可以发通知出去告诉设备连接界面连接失败
        
    }
    
    // MARK: 连接丢失
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "DidDisConnectPeriphernalNotification"), object: nil, userInfo: ["deviceList": self.deviceList as AnyObject])
        
        // 这里可以发通知出去告诉设备连接界面连接丢失
        
    }
    
}


// 外设的代理
extension LLBlueTooth : CBPeripheralDelegate {
    
    //MARK: - 匹配对应服务UUID
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
        
        if error != nil {
            return
        }
        
        for service in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service )
        }
        
    }
    
    //MARK: - 服务下的特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
        delegate?.peripheral!(peripheral, didDiscoverCharacteristicsFor: service, error: error)
        if (error != nil){
            return
        }
        
        for  characteristic in service.characteristics! {
            print(characteristic.uuid.description)
            switch characteristic.uuid.description {
                
//            case "A28DA977":
//                // 订阅特征值，订阅成功后后续所有的值变化都会自动通知
//                peripheral.setNotifyValue(true, for: characteristic)
            case kDataCharacteristic:
                // 订阅特征值，订阅成功后后续所有的值变化都会自动通知
                peripheral.setNotifyValue(true, for: characteristic)
                sendCharacteristic = characteristic
            case "******":
                // 读区特征值，只能读到一次
                peripheral.readValue(for:characteristic)
            default:
                print("扫描到其他特征")
            }
            
        }
        
    }
    
    //MARK: - 特征的订阅状体发生变化
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?){
        
        guard error == nil  else {
            return
        }
        
    }
    
    // MARK: - 获取外设发来的数据
    // 注意，所有的，不管是 read , notify 的特征的值都是在这里读取
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)-> (){
        
        if(error != nil){
            return
        }
        
        switch characteristic.uuid.uuidString {
        case kDataCharacteristic:
            let string = String.init(data: characteristic.value!, encoding: .utf8)
            print(string ?? "no data")
//            print("接收到了设备的Data Characteristic的变化")
        default:
            print("收到了其他数据特征数据: \(characteristic.uuid.uuidString)")
        }
    
    }
    
    
    
    //MARK: - 检测中心向外设写数据是否成功
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if(error != nil){
            print("发送数据失败!error信息:\(String(describing: error))")
        }else{
            print("成功")
        }
        
    }
    
}
