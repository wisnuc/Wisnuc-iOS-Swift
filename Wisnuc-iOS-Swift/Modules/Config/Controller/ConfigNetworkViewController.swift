//
//  ConfigNetworkViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/13.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork
import NetworkExtension
import CoreBluetooth

enum ConfigNetworkViewControllerState {
    case initialization
    case change
}

class ConfigNetworkViewController: BaseViewController {
    let cellIdentifer = "celled"
    var textFieldControllerNetworkName:MDCTextInputControllerUnderline?
    var textFieldControllerPassword:MDCTextInputControllerUnderline?
    var isNetworkNameTrue = false
    var deviceModel:DeviceBLEModel?
    var wifiBLEDataArray:[String] = Array.init()
    var wifiBLEArray:[String] = Array.init(){
        didSet{
            self.wifiTabelView.reloadData()
        }
    }
    var state:ConfigNetworkViewControllerState?{
        didSet{
            switch state {
            case .change?:
                changeStateAction()
            case .initialization?:
                initializationStateAction()
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareNotification()
        self.view.addSubview(titleLabel)
        self.view.addSubview(networkNameTitleLabel)
        self.view.addSubview(networkNameTextFiled)
        self.view.addSubview(passwordTitleLabel)
        self.view.addSubview(passwordTextFiled)
        self.setTextFieldController()
        self.view.addSubview(nextButton)
        self.view.addSubview(errorLabel)
        self.view.addSubview(wifiTabelView)
        tableViewContainerView.isHidden = true
        setTableViewContent()
        // Do any additional setup after loading the view.
    }
    
    init(style:NavigationStyle,state:ConfigNetworkViewControllerState) {
        super.init(style: style)
        setState(state)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         LLBlueTooth.instance.delegate = self
        if nextButton.isHidden{
            nextButton.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NetworkStatus.getNetworkStatus { (status) in
            switch status {
            case .WIFI:
                self.networkNameTextFiled.text = self.getWifiInfo().ssid
            default:
                self.networkNameTextFiled.text = LocalizedString(forKey: "未连接Wi-Fi")
            }
        }
        
    }
    
    deinit {
        defaultNotificationCenter().removeObserver(self)
    }
    
    func prepareNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(note:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //键盘即将隐藏
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden(note:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func setState(_ state:ConfigNetworkViewControllerState){
        self.state = state
    }
    
    func changeStateAction(){
        self.titleLabel.text = LocalizedString(forKey: "切换Wi-Fi")
    }
    
    func initializationStateAction(){
        self.titleLabel.text = LocalizedString(forKey: "设置Wi-Fi")
    }
    
    func getWifiInfo() -> (ssid: String?, mac: String?) {
        if #available(iOS 11.0, *) {
            NEHotspotConfigurationManager.shared.getConfiguredSSIDs { (strings) in
                print("😆\(strings)")
            }
        } else {
            // Fallback on earlier versions
        }
        
        if let cfas: NSArray = CNCopySupportedInterfaces() {
            for cfa in cfas {
                if let dict = CFBridgingRetain(
                    CNCopyCurrentNetworkInfo(cfa as! CFString)
                    ) {
                    if let ssid = dict["SSID"] as? String,
                        let bssid = dict["BSSID"] as? String {
                        return (ssid, bssid)
                    }
                }
            }
        }
        return (nil, nil)
    }

    func setTextFieldController(){
        self.textFieldControllerNetworkName = MDCTextInputControllerUnderline.init(textInput: networkNameTextFiled)
        self.textFieldControllerNetworkName?.isFloatingEnabled = false
        //        self.textFieldControllerPhoneNumber?.placeholderText = LocalizedString(forKey: "password_text")
        self.textFieldControllerNetworkName?.normalColor = UIColor.black.withAlphaComponent(0.06)
        self.textFieldControllerNetworkName?.activeColor = COR1
        self.textFieldControllerPassword = MDCTextInputControllerUnderline.init(textInput: passwordTextFiled)
        self.textFieldControllerPassword?.isFloatingEnabled = false
        //        self.textFieldControllerPhoneNumber?.placeholderText = LocalizedString(forKey: "password_text")
        self.textFieldControllerPassword?.normalColor = UIColor.black.withAlphaComponent(0.06)
        self.textFieldControllerPassword?.activeColor = COR1
    }
    
    func setTableViewContent(){
        self.view.addSubview(tableViewContainerView)
        tableViewContainerView.addSubview(self.wifiTabelView)
    }
    
    func leftView(image:UIImage?) -> UIView{
        let leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: 24 + 12, height: 24))
        let imageView = UIImageView.init(image:image)
        leftView.layer.cornerRadius = 2
        imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        leftView.addSubview(imageView)
        leftView.backgroundColor = .clear
        return leftView
    }
    
    func rightView(type:RightViewType) -> UIImageView{
        var image:UIImage?
        switch type {
        case .right:
            image = UIImage.init(named: "up_arrow_gray")
        case .password:
            image = UIImage.init(named: "eye_open_gray")
        default:
            break
        }
        
        let imageView = RightImageView.init(image:image)
        imageView.tintColor = .white
        imageView.type = type
        imageView.frame = CGRect(x: 0, y: 0, width: image?.width ?? CGSize.zero.width , height: image?.height ?? CGSize.zero.height)
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(rightViewTap(_ :)))
        imageView.addGestureRecognizer(tap)
        return imageView
    }
    
    func nextButtonDisableStyle(){
        self.nextButton.backgroundColor = COR1.withAlphaComponent(0.26)
        self.nextButton.isEnabled = false
    }
    
    func nextButtonEnableStyle(){
        self.nextButton.backgroundColor = COR1
        self.nextButton.isEnabled = true
    }
    
    func spreadOut(){
        self.tableViewContainerView.isHidden = false
    }
    
    func sendData(){
        guard let model = self.deviceModel else {
            return
        }
        guard let peripheral = model.peripheral else {
            return
        }
        guard let characteristic = model.spsDataCharacteristic else {
            return
        }
        let dataString = "scan\n"
        let packet : [UInt8] = [UInt8](dataString.utf8)
        let data = Data.init(bytes: packet)
        LLBlueTooth.instance.send(data: data) { (subData) in
            if let subData = subData {
            let dataString = String.init(data: subData, encoding: .utf8)
            print(dataString ?? "No data")
            LLBlueTooth.instance.writeToPeripheral(peripheral: peripheral, characteristic: characteristic, data: subData, writeType: CBCharacteristicWriteType.withoutResponse)
            usleep(20 * 1000)
            }
        }
    }
    
    
    @objc func nextButtontTap(_ sender:MDCFloatingButton){
        self.networkNameTextFiled.resignFirstResponder()
        self.passwordTextFiled.resignFirstResponder()
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        SVProgressHUD.show(withStatus: LocalizedString(forKey: "Wi-Fi配置中"))
        sender.isHidden = true
        DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 3) {
            DispatchQueue.main.async {
                 SVProgressHUD.dismiss()
                let identifyingFromDeviceVC = IdentifyingFromDeviceViewController.init(style: NavigationStyle.whiteWithoutShadow)
                self.navigationController?.pushViewController(identifyingFromDeviceVC, animated: true)
            }
        }
    }
    
    
    @objc func rightViewTap(_ gestrue:UIGestureRecognizer){
        if (gestrue.view?.isKind(of: RightImageView.self))!{
            let rightView = gestrue.view as! RightImageView
            switch rightView.type {
            case .password?:
                rightView.isSelect = !rightView.isSelect
                if rightView.isSelect{
                    rightView.image = UIImage.init(named: "eye_close_gary.png")
                    self.passwordTextFiled.isSecureTextEntry = false
                }else{
                    rightView.image = UIImage.init(named: "eye_open_gary.png")
                    self.passwordTextFiled.isSecureTextEntry = true
                }
            case .right?:
                rightView.isSelect = !rightView.isSelect
                if rightView.isSelect{
                    rightView.image = UIImage.init(named: "down_arrow_gray.png")
                    self.sendData()
                    self.tableViewContainerView.isHidden = false
                    ActivityIndicator.startActivityIndicatorAnimation(in: wifiTabelView)
                }else{
                    rightView.image = UIImage.init(named: "up_arrow_gray.png")
                    self.tableViewContainerView.isHidden = true
                }
            default:
                break
            }
        }
    }
    
    //键盘弹出监听
    @objc func keyboardShow(note: Notification)  {
        guard let userInfo = note.userInfo else {return}
        guard let keyboardRect = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else{return}
        //获取键盘弹起的高度
        let keyboardTopYPosition =  keyboardRect.origin.y
        let duration = note.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        var nextButtonCenter = CGPoint(x: self.nextButton.center.x, y: keyboardTopYPosition - 36)
        if  is47InchScreen {
            nextButtonCenter  = CGPoint(x: self.nextButton.center.x, y: keyboardTopYPosition)
        }
        
        UIView.animate(withDuration: duration) {
            self.nextButton.center = nextButtonCenter
        }
    }
    
    //键盘隐藏监听
    @objc func keyboardHidden(note: Notification){
        guard let userInfo = note.userInfo else {return}
        guard let keyboardRect = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else{return}
        //        //获取键盘弹起的高度
        let keyboardTopYPosition = keyboardRect.origin.y
        let duration = note.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration) {
            self.nextButton.center = CGPoint(x: self.nextButton.center.x, y: keyboardTopYPosition - MarginsWidth - self.nextButton.height/2)
        }
    }
    

    lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: MarginsWidth + MDCAppNavigationBarHeight, width: __kWidth - MarginsWidth*2, height: 22))
        label.font = UIFont.boldSystemFont(ofSize: 21)
        label.textColor = DarkGrayColor
        return label
    }()
    
    lazy var networkNameTitleLabel: UILabel = {  [weak self] in
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: (self?.titleLabel.bottom)! + 46, width: __kWidth - MarginsWidth*2, height: 12))
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = DarkGrayColor
        label.text = LocalizedString(forKey: "Wi-Fi")
        return label
        }()
    
    lazy var networkNameTextFiled: MDCTextField = {  [weak self] in
        let textInput = MDCTextField.init(frame: CGRect(x: MarginsWidth, y: (self?.networkNameTitleLabel.bottom)! + MarginsWidth, width: __kWidth - MarginsWidth*2, height: 80))
        textInput.leftViewMode = .always
        textInput.textColor = DarkGrayColor
        textInput.font = UIFont.systemFont(ofSize: 16)
        textInput.leftView = self?.leftView(image: UIImage.init(named: "wifi_config.png"))
        if #available(iOS 10.0, *) {
            textInput.adjustsFontForContentSizeCategory = true
        } else {
            textInput.mdc_adjustsFontForContentSizeCategory = true
        }
        textInput.clearButtonMode = .never
        textInput.rightViewMode = .always
        textInput.rightView = rightView(type: RightViewType.right)
        textInput.delegate = self
        if is47InchScreen{
            textInput.keyboardDistanceFromTextField = 160
        }
        return textInput
        }()
    
    lazy var passwordTitleLabel: UILabel = {  [weak self] in
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: (self?.networkNameTextFiled.bottom)! + 16, width: __kWidth - MarginsWidth*2, height: 12))
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = DarkGrayColor
        label.text = LocalizedString(forKey: "密码")
        
        return label
        }()
    
    lazy var passwordTextFiled: MDCTextField = { [weak self] in
        let textInput = MDCTextField.init(frame: CGRect(x: MarginsWidth, y: (self?.passwordTitleLabel.bottom)! + MarginsWidth, width: __kWidth - MarginsWidth*2, height: 80))
        textInput.leftViewMode = .always
        textInput.textColor = DarkGrayColor
        textInput.font = UIFont.systemFont(ofSize: 16)
        textInput.isSecureTextEntry = true
        textInput.leftView = self?.leftView(image: UIImage.init(named: "lock_config.png"))
        
        if #available(iOS 10.0, *) {
            textInput.adjustsFontForContentSizeCategory = true
        } else {
            textInput.mdc_adjustsFontForContentSizeCategory = true
        }
        textInput.clearButtonMode = .never
        textInput.rightView = rightView(type: RightViewType.password)
        textInput.rightViewMode = .always
        textInput.delegate = self
        if is47InchScreen{
            textInput.keyboardDistanceFromTextField = 36
        }
        return textInput
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton.init(type: .custom)
        let width:CGFloat = 40
        button.frame = CGRect(x: __kWidth - MarginsWidth - width , y: __kHeight - MarginsWidth - width, width: width, height: width)
        button.setImage(UIImage.init(named: "next_button_arrow_white"), for: UIControlState.normal)
        button.backgroundColor = COR1.withAlphaComponent(0.26)
        button.isEnabled = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = width/2
        button.addTarget(self, action: #selector(nextButtontTap(_:)), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var errorLabel: UILabel = {  [weak self] in
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: (self?.passwordTextFiled.bottom)! + 48, width: __kWidth - MarginsWidth*2, height: 22))
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.init(rgb: 0x0f44336)
        return label
    }()
    
    lazy var tableViewContainerView: UIView = { [weak self] in
        let containerView:UIView = UIView(frame: CGRect(x: MarginsWidth, y: (self?.networkNameTextFiled.bottom)! - 20, width: __kWidth - MarginsWidth*2, height: 200))
        self?.wifiTabelView.frame = containerView.bounds
        containerView.backgroundColor = UIColor.clear
        
        containerView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        containerView.layer.shadowRadius = 1
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.shadowColor = DarkGrayColor.cgColor
        return containerView
    }()
    
    lazy var wifiTabelView: UITableView = {  [weak self] in
        let tableView = UITableView.init()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.masksToBounds = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifer)
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        return tableView
    }()

}

extension ConfigNetworkViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let rawText = textField.text else {
            return true
        }
        
        let fullString = NSString(string: rawText).replacingCharacters(in: range, with: string)
        print(fullString)
        if fullString.count >= 0 && !isNilString(networkNameTextFiled.text){
            self.nextButtonEnableStyle()
        }else{
            self.nextButtonDisableStyle()
        }
        return true
    }
}

extension ConfigNetworkViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wifiBLEArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorStyle = .none
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifer, for: indexPath)
        let string = wifiBLEArray[indexPath.row]
        cell.contentView.removeAllSubviews()
        let label = UILabel.init(frame: CGRect(x: 24 + 12, y: 0, width:__kWidth - MarginsWidth*2 - 24 + 12 , height: 44))
        label.textColor = DarkGrayColor
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.text = string
        cell.contentView.addSubview(label)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let string = wifiBLEArray[indexPath.row]
        self.networkNameTextFiled.text = string
        tableViewContainerView.isHidden = true
    }
}


extension ConfigNetworkViewController:LLBlueToothDelegate{
    func didDiscoverPeripheral(_ peripheral: CBPeripheral) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    func peripheralCharacteristicDidUpdateValue(deviceBLEModels: [DeviceBLEModel]?) {
        
    }
    

    func peripheralStationSPSCharacteristicDidUpdateValue(data:Data){        
        if let string = String.init(data: data, encoding: String.Encoding.utf8){
            wifiBLEDataArray.append(string)
            let bleString = wifiBLEDataArray.joined()
            guard let bleData = bleString.data(using: String.Encoding.utf8) else{
                return
            }
            
            do {
                if let wifiArray = try JSONSerialization.jsonObject(with:bleData, options: .mutableContainers) as? Array<String>{
//                    print("😝\(wifiArray)")
                   
                    wifiBLEArray = wifiArray
                    ActivityIndicator.stopActivity(in: self.wifiTabelView)
                }
            } catch  {
               print(error)
            }
        }
    }
}

