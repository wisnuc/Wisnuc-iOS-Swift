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



let kStationIdCharacteristic = "F000BEF1-0451-4000-B000-000000000000"
let kStationStatusCharacteristic = "F000BEF2-0451-4000-B000-000000000000"
let kBindingProgressCharacteristic = "F000BEF3-0451-4000-B000-000000000000"

let kStationeSessionCharacteristic = "F000BEF4-0451-4000-B000-000000000000"
let kSPSDataCharacteristic = "F000C0E1-0451-4000-B000-000000000000"

let BLE_SEND_MAX_LEN = 18

@objc protocol LLBlueToothDelegate {
    func didDiscoverPeripheral(_ peripheral:CBPeripheral)
    @objc optional func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral)
    func centralManagerDidUpdateState(_ central: CBCentralManager)
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)-> ()
    
    func peripheralCharacteristicDidUpdateValue(deviceBLEModels:[DeviceBLEModel]?)
    @objc optional func peripheralStationSPSCharacteristicDidUpdateValue(data:Data)
}

//@objc protocol LLBlueToothDataDelegate {
//    @objc optional func peripheralStationSPSCharacteristicDidUpdateValue(data:Data)
//}



//用于看发送数据是否成功!
class LLBlueTooth:NSObject {
    
    weak var delegate:LLBlueToothDelegate?{
        didSet{
        }
   
    }
    
    struct Static
    {
        static var instance: LLBlueTooth?
    }
    
    class var sharedInstance: LLBlueTooth
    {
        if Static.instance == nil
        {
            Static.instance = LLBlueTooth()
        }
        
        return Static.instance!
    }
    
    func dispose()
    {
        LLBlueTooth.Static.instance = nil
        print("Disposed Singleton instance")
    }
    
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
    
    var deviceDatas: [DeviceBLEModel]?{
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
        
        self.deviceDatas = [DeviceBLEModel]()
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
    func writeToPeripheral(characteristic:CBCharacteristic,data: Data,writeType:CBCharacteristicWriteType) {
        peripheral.writeValue(data , for: characteristic, type:writeType)
    }
    
    func writeToPeripheral(peripheral:CBPeripheral,characteristic:CBCharacteristic,data: Data,writeType:CBCharacteristicWriteType) {
        peripheral.writeValue(data , for: characteristic, type:writeType)
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
    func requestConnectPeripheral(_ peripheral:CBPeripheral) {
        
        if (peripheral.state != CBPeripheralState.connected) {
            
            central?.connect(peripheral , options: nil)
            
        }
        
    }
    
    func disConnectPeripheral(_ peripheral:CBPeripheral) {
        
        if (peripheral.state == CBPeripheralState.connected) {
            
            central?.cancelPeripheralConnection(peripheral)
            
        }
        
    }
    
    func disConnectPeripherals(_ peripherals:[CBPeripheral]) {
        for peripheral in peripherals{
             central?.cancelPeripheralConnection(peripheral)
        }
    }
    
    func send(data msgData: Data, send: @escaping (_ finished: Data?) -> ()) {
        var i = 0
        while i < msgData.count {
            // 预加 最大包长度，如果依然小于总数据长度，可以取最大包数据大小
            if (i + BLE_SEND_MAX_LEN) < msgData.count {
                let rangeStr = String(format: "%i,%i", i, BLE_SEND_MAX_LEN)
                if let range = Range.init(NSRangeFromString(rangeStr)){
                    let subData = msgData.subdata(in:range)
                    send(subData)
                }
                //    NSString *result = [[NSString alloc] initWithData:subData  encoding:NSUTF8StringEncoding];
                //            NSLog(@"%@",result);
                //根据接收模块的处理能力做相应延时
            } else {
                let rangeStr = String(format: "%i,%i", i, Int(msgData.count - i))
                if let range = Range.init(NSRangeFromString(rangeStr)){
                    let subData = msgData.subdata(in: range)
                    send(subData)
                }
              
//                var result = String(data: subData, encoding: .utf8)
                //            NSLog(@"%@",result);
            }
            i += BLE_SEND_MAX_LEN
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
        delegate?.peripheral?(peripheral, didDiscoverCharacteristicsFor: service, error: error)
        if (error != nil){
            return
        }
        let model = DeviceBLEModel.init()
        model.peripheral = peripheral
        for  characteristic in service.characteristics! {
            print(characteristic.uuid.description)
            switch characteristic.uuid.description {
            case kStationIdCharacteristic:
                // 读区特征值，只能读到一次
                peripheral.readValue(for:characteristic)
                
            case kStationStatusCharacteristic:

                peripheral.readValue(for:characteristic)
                
            case kBindingProgressCharacteristic:

                peripheral.setNotifyValue(true, for: characteristic)
                
            case kStationeSessionCharacteristic:
                
                peripheral.setNotifyValue(true, for: characteristic)
                
            case kSPSDataCharacteristic:
                // 订阅特征值，订阅成功后后续所有的值变化都会自动通知
                peripheral.setNotifyValue(true, for: characteristic)
                
                model.spsDataCharacteristic = characteristic

            default:
                print("扫描到其他特征")
            }
            
            if let index = deviceDatas?.firstIndex(where: {$0.peripheral?.identifier == peripheral.identifier}){
                if let deviceModel  = deviceDatas?[index]{
                    if let spsDataCharacteristic = model.spsDataCharacteristic{
                        deviceModel.spsDataCharacteristic = spsDataCharacteristic
                    }
                    deviceDatas?[index] = deviceModel
                }
            }else{
                deviceDatas?.append(model)
            }
        }
        
    }
    
    //MARK: - 特征的订阅状体发生变化
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?){
        
        guard error == nil  else {
            return
        }
        print(error as Any)
        
    }
    
    // MARK: - 获取外设发来的数据
    // 注意，所有的，不管是 read , notify 的特征的值都是在这里读取
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?)-> (){
        self.delegate?.peripheral(peripheral, didUpdateValueFor: characteristic, error: error)
        if(error != nil){
            return
        }
        let model = DeviceBLEModel.init()
        model.peripheral = peripheral
        var stationId:String?
        switch characteristic.uuid.uuidString {
        case kStationIdCharacteristic:
           if let string = String.init(data: characteristic.value!, encoding: .utf8){
                stationId = string
                model.stationId = stationId
            }
        case kStationStatusCharacteristic:
            let data = characteristic.value
            var byte:UInt8 = 0
            data?.copyBytes(to: &byte, count: 1)
            let valueInInt = Int(byte)
            print(valueInInt)
            if let deviceType = DeviceBLEModelType(rawValue: valueInInt){
                model.type = deviceType
            }
            
            let string = String.init(data: characteristic.value!, encoding: .ascii)
            print(string ?? "no data")
       
        case kSPSDataCharacteristic:
            if let data = characteristic.value{
                if let updateValue = self.delegate?.peripheralStationSPSCharacteristicDidUpdateValue{
                    updateValue(data)
                }
            }
            if  let string = String.init(data: characteristic.value!, encoding: .utf8){
                print(string)
                
            }
//            print("接收到了设备的Data Characteristic的变化")
        case kStationeSessionCharacteristic:
            let string = String.init(data: characteristic.value!, encoding: .utf8)
            print(string ?? "no data")
            
        case kBindingProgressCharacteristic:
            let string = String.init(data: characteristic.value!, encoding: .utf8)
            print(string ?? "no data")
        default:
            print("收到了其他数据特征数据: \(characteristic.uuid.uuidString)")
        }
//        guard let id = stationId else {
//            return
//        }
//

        if let index = deviceDatas?.firstIndex(where: {$0.peripheral?.identifier == peripheral.identifier}){
            if let deviceModel = deviceDatas?[index]{
                if let stationId =  model.stationId{
                    deviceModel.stationId = stationId
                }
                if let type =  model.type{
                    deviceModel.type = type
                }
                deviceDatas?[index] = deviceModel
            }
        }

        delegate?.peripheralCharacteristicDidUpdateValue(deviceBLEModels: deviceDatas)
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
