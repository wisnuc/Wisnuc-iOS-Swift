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
import Alamofire

enum ConfigNetworkViewControllerState {
    case initialization
    case change
    case add
}

class ConfigNetworkViewController: BaseViewController {
    let cellIdentifer = "celled"
    var textFieldControllerNetworkName:MDCTextInputControllerUnderline?
    var textFieldControllerPassword:MDCTextInputControllerUnderline?
    var isNetworkNameTrue = false
    var deviceModel:DeviceBLEModel?
    var infoModel:WinasdInfoModel?
    var user:User?
    var methodStart:Date?
    var methodFinish:Date?
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
            case .initialization?,.add?:
                initializationStateAction()
            default:
                break
            }
        }
    }
    
    var seekNewDeviceState:SeekNewDeviceState?{
        didSet{
            switch seekNewDeviceState {
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
    
    init(style:NavigationStyle,state:ConfigNetworkViewControllerState,user:User? = nil) {
        super.init(style: style)
        setState(state)
        self.user = user
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
        if self.state == .change{
            LLBlueTooth.instance.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didViewAppearAction()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.state == .change{
            LLBlueTooth.instance.stopScan()
        }
    }
    
    deinit {
        defaultNotificationCenter().removeObserver(self)
        LLBlueTooth.instance.disConnectPeripherals(dataPeripheralList)
        LLBlueTooth.instance.dispose()
    }
    
    func didViewAppearAction(){
        if self.state == .change{
           fetchCurrentDeviceNetwork()
        }else{
           fetchCurrentPhoneNetwork()
        }
    }
    
    func fetchCurrentDeviceNetwork(){
        DeviceHelper.fetchInasdInfo (closure:{ [weak self](model) in
            self?.infoModel = model
            self?.wifiTabelView.reloadData()
            if let essid = model?.net?.networkInterface?.essid{
                self?.networkNameTextFiled.text = essid
            }
        })
    }
    
    func fetchCurrentPhoneNetwork(){
        NetworkStatus.getNetworkStatus { (status) in
            switch status {
            case .WIFI:
                self.networkNameTextFiled.text = self.getWifiInfo().ssid
            default:
                self.networkNameTextFiled.text = LocalizedString(forKey: "未连接Wi-Fi")
            }
        }
    }
    
    func searchingStateAction(){
        let options =  [CBCentralManagerScanOptionAllowDuplicatesKey:false]
        LLBlueTooth.instance.scanForPeripheralsWithServices(nil, options: options as [String : AnyObject])
    }
    
    func notFoundStateAction(){
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.show(withStatus: LocalizedString(forKey: "未发现设备"))
    }
    
    func foundStateAction(){
    }
    
    func  bleNotOpenAction(){
        dataSource.removeAll()
        dataPeripheralList.removeAll()
        SVProgressHUD.showError(withStatus: LocalizedString(forKey: "蓝牙未开启"))
    }

    func prepareNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(note:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //键盘即将隐藏
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden(note:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        defaultNotificationCenter().addObserver(self, selector: #selector(progressHUDDisappear(_:)), name: NSNotification.Name.SVProgressHUDDidDisappear,object: nil)
    }
    
    func setState(_ state:ConfigNetworkViewControllerState){
        self.state = state
    }
    
    func changeStateAction(){
        self.titleLabel.text = LocalizedString(forKey: "切换Wi-Fi")
        self.seekNewDeviceState = .searching
    }
    
    func initializationStateAction(){
        self.titleLabel.text = LocalizedString(forKey: "设置Wi-Fi")
    }
    
    func getWifiInfo() -> (ssid: String?, mac: String?) {
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
        self.textFieldControllerNetworkName?.normalColor = UIColor.black.withAlphaComponent(0.06)
        self.textFieldControllerNetworkName?.activeColor = COR1
        self.textFieldControllerPassword = MDCTextInputControllerUnderline.init(textInput: passwordTextFiled)
        self.textFieldControllerPassword?.isFloatingEnabled = false
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
    
    //打开下拉框
    func spreadOut(rightView:RightImageView?){
        rightView?.isSelect = true
        rightView?.image = UIImage.init(named: "down_arrow_gray.png")
        let param = ["action":"scan"]
        self.sendData(param)
        self.tableViewContainerView.isHidden = false
        ActivityIndicator.startActivityIndicatorAnimation(in: wifiTabelView)
    }
    
    //关闭下拉框
    func spreadIn(rightView:RightImageView?){
         rightView?.isSelect = false
        rightView?.image = UIImage.init(named: "up_arrow_gray.png")
        self.tableViewContainerView.isHidden = true
        ActivityIndicator.stopActivity(in: self.wifiTabelView)
        wifiBLEArray.removeAll()
        wifiBLEDataArray.removeAll()
    }

    //分包发送
    func sendData(_ param:[String:String]){
        guard let model = self.deviceModel else {
            return
        }
        guard let peripheral = model.peripheral else {
            return
        }
        guard let characteristic = model.spsDataCharacteristic else {
            return
        }
        let string = jsonToString(json: param, prettyPrinted: false)
        let dataString = "\(string)\n"
        print(dataString)
        let packet : [UInt8] = [UInt8](dataString.utf8)
        let data = Data.init(bytes: packet)
        LLBlueTooth.instance.send(data: data) { (subData) in
            if let subData = subData {
            let dataString = String.init(data: subData, encoding: .utf8)
            print(dataString ?? "No data")
            LLBlueTooth.instance.writeToPeripheral(peripheral: peripheral, characteristic: characteristic, data: subData, writeType: CBCharacteristicWriteType.withoutResponse)
            }
        }
    }
    
    //验证
    func stationEncryptedAction(ipString:String){
        SVProgressHUD.dismiss()
        ActivityIndicator.startActivityIndicatorAnimation()
        AppNetworkService.networkState = .normal
        BindStationAPI.init(user:self.user).startRequestJSONCompletionHandler { [weak self] (response) in
            if let error = response.error{
                ActivityIndicator.stopActivityIndicatorAnimation()
                var messageText = error.localizedDescription
                if response.error is BaseError{
                    messageText =  (response.error as! BaseError).localizedDescription
                }
                Message.message(text:messageText)
            }else{
                if let errorString = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorString)
                }else{
                    if let rootDic = response.value as? NSDictionary{
                        guard let dataDic = rootDic["data"] as? NSDictionary else{
                            Message.message(text:LocalizedString(forKey: "error"))
                            return
                        }
                        
                        guard  let encryptedString = dataDic["encrypted"] as? String else{
                            Message.message(text:LocalizedString(forKey: "error"))
                            return
                        }
                        let userInfo:[String:String] = ["encrypted":encryptedString,"ip":ipString]
                        self?.methodStart = Date()
                        if let header = response.response?.allHeaderFields  {
                            if let cookie = header["Set-Cookie"] as? String  {
                                self?.user?.cookie = cookie
                            }
                        }
                        DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 3) {
                            DispatchQueue.main.async {
                                self?.timerFired(userInfo)
                            }
                        }
                    }
                }
            }
        }
    }
    
    //绑定
    func stationBindAction(ipString:String,encryptedString:String){
        ActivityIndicator.startActivityIndicatorAnimation()
        let parameters = ["encrypted":encryptedString]
        let urlString = "http://\(ipString):3001/bind"
        let requset = Alamofire.request(urlString, method: .post,parameters: parameters, encoding:JSONEncoding.default)
        requset.validate().responseJSON { [weak self] (response) in
             ActivityIndicator.stopActivityIndicatorAnimation()
            if let error = response.error{
                let messageText = error.localizedDescription
                Message.message(text:messageText)
            }else{
                print(response.value as Any)
                if self?.state == .add{
                    Message.message(text: LocalizedString(forKey: "添加设备成功"))
                    return
                }
                if let dataDic = response.value as? NSDictionary{
                    if let userId = dataDic["id"] as? String{
                        self?.stationFetchAction(userId)
                    }
                }
            }
        }
    }
    
    func stationFetchAction(_ userId:String){
        ActivityIndicator.startActivityIndicatorAnimation()
        guard let token = user?.cloudToken else {
            ActivityIndicator.stopActivityIndicatorAnimation()
            Message.message(text: LocalizedString(forKey:"error:No token"))
            return
        }

        LoginCommonHelper.instance.getStations(token:token) { [weak self](error, models,lastSn)  in
            ActivityIndicator.stopActivityIndicatorAnimation()
            if error == nil{
                if let models = models{
                    if models.count > 0{
                        self?.loginAction(userId: userId, model: models.first!)
                    }else{
                        Message.message(text: LocalizedString(forKey:"error:No station"))
                    }
                }
                print(models as Any)
            }else{
                switch error{
                case is LoginError :
                    let loginError = error as! LoginError
                    if loginError.kind == LoginError.ErrorKind.LoginNoBindDevice || loginError.kind == LoginError.ErrorKind.LoginNoOnlineDevice || loginError.kind == LoginError.ErrorKind.LoginRequestError {
                        Message.message(text: LocalizedString(forKey: loginError.localizedDescription), duration:2.0)
                    }else  {
                        Message.message(text: LocalizedString(forKey:"\(String(describing: loginError.localizedDescription))"),duration:2.0)
                    }
                case is BaseError :
                    let baseError = error as! BaseError
                    Message.message(text: LocalizedString(forKey:"\(String(describing: baseError.localizedDescription))"),duration:2.0)
                default:
                    Message.message(text: LocalizedString(forKey:"\(String(describing: (error?.localizedDescription)!))"),duration:2.0)
                }
                ActivityIndicator.startActivityIndicatorAnimation()
                print(error as Any)
            }
        }
    }
    
    //首配后登录
    func loginAction(userId:String,model:StationsInfoModel){
        ActivityIndicator.startActivityIndicatorAnimation()
        guard let user = self.user else {
            return
        }
        
        if user.uuid != userId{
            return
        }
            AppService.sharedInstance().loginAction(stationModel: model, orginTokenUser: user) { (error, userData) in
                if error == nil && userData != nil{
                    AppUserService.isUserLogin = true
                    AppUserService.isStationSelected = true
                    AppUserService.setCurrentUser(userData)
                    AppUserService.currentUser?.isSelectStation = NSNumber.init(value: AppUserService.isStationSelected)
                    AppUserService.synchronizedCurrentUser()
                    let identifyingFromDeviceVC = IdentifyingFromDeviceViewController.init(style: NavigationStyle.whiteWithoutShadow)
                        self.navigationController?.pushViewController(identifyingFromDeviceVC, animated: true)
                }else{
                    if error != nil{
                        switch error {
                        case is LoginError:
                            let loginError = error as! LoginError
                            Message.message(text: loginError.localizedDescription, duration: 2.0)
                        case is BaseError:
                            let baseError = error as! BaseError
                            Message.message(text: baseError.localizedDescription, duration: 2.0)
                        default:
                            Message.message(text: (error?.localizedDescription)!, duration: 2.0)
                        }
//                        AppUserService.logoutUser()
                        ActivityIndicator.stopActivityIndicatorAnimation()
                    }
                }
            }

    }
    
    
    @objc func nextButtontTap(_ sender:MDCFloatingButton){
        guard let ssidTxt = self.networkNameTextFiled.text else {
            Message.message(text: LocalizedString(forKey: "Wi-Fi名称不能为空"))
            return
        }
        
        if ssidTxt.count == 0 {
            Message.message(text: LocalizedString(forKey: "Wi-Fi名称不能为空"))
            return
        }
        
        guard let passwordTxt = self.passwordTextFiled.text else {
            Message.message(text: LocalizedString(forKey: "Wi-Fi密码不能为空"))
            return
        }
        
        if passwordTxt.count == 0 {
            Message.message(text: LocalizedString(forKey: "Wi-Fi密码不能为空"))
            return
        }
        
        self.networkNameTextFiled.resignFirstResponder()
        self.passwordTextFiled.resignFirstResponder()
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        SVProgressHUD.show(withStatus: LocalizedString(forKey: "Wi-Fi配置中"))
        SVProgressHUD.setMaximumDismissTimeInterval(20)
        self.wifiBLEDataArray.removeAll()
        sender.isHidden = true
        let param = ["action":"conn","ssid":ssidTxt,"password":passwordTxt]
        self.sendData(param)
    }
    
    
    @objc func rightViewTap(_ gestrue:UIGestureRecognizer){
        if (gestrue.view?.isKind(of: RightImageView.self))!{
            let rightView = gestrue.view as! RightImageView
            switch rightView.type {
            case .password?:
                rightView.isSelect = !rightView.isSelect
                if rightView.isSelect{
                    rightView.image = UIImage.init(named: "eye_open_gray.png")
                    self.passwordTextFiled.isSecureTextEntry = false
                }else{
                    rightView.image = UIImage.init(named: "eye_close_gray.png")
                    self.passwordTextFiled.isSecureTextEntry = true
                }
            case .right?:
                rightView.isSelect = !rightView.isSelect
                if rightView.isSelect{
                    self.spreadOut(rightView: rightView)
                }else{
                    self.spreadIn(rightView: rightView)
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
    @objc func progressHUDDisappear(_ note: Notification){
        guard let userInfo = note.userInfo else {return}
        guard let string = userInfo[SVProgressHUDStatusUserInfoKey] as? String else{return}
    }
    
    
     func timerFired(_ userInfo: [String:String]) {
        
        guard let ipString = userInfo["ip"] else{
            return
        }
        
        guard let encryptedString = userInfo["encrypted"] else{
            return
        }
        
        AppNetworkService.checkIP(address: ipString, { [weak self](success) in
            if success{
                self?.stationBindAction(ipString: ipString, encryptedString:encryptedString)
            }else{
                ActivityIndicator.stopActivityIndicatorAnimation()
                Message.message(text: "error")
                self?.methodFinish = Date()
                guard let methodFinish = self?.methodFinish else{
                    return
                }
                if let methodStart = self?.methodStart{
                    
                    let executionTime = methodFinish.timeIntervalSince(methodStart)
                    if executionTime > 30{
                    }
                }
            }
        })
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

    lazy var dataSource:Array<DeviceBLEModel> = [DeviceBLEModel]()
    lazy var dataPeripheralList:Array<CBPeripheral> = [CBPeripheral]()
    var bleUsedArray: [String] {
        get{
            if let userId = AppUserService.currentUser?.uuid{
                if let array = userDefaults.array(forKey: "\(kBLEUsedKey)_\(userId)") as? [String]{
                    return array
                }else{
                    let bleArray:[String] = [String]()
                    return bleArray
                }
            }else if let userId = self.user?.uuid{
                if let array = userDefaults.array(forKey: "\(kBLEUsedKey)_\(userId)") as? [String]{
                    return array
                }else{
                    let bleArray:[String] = [String]()
                    return bleArray
                }
               
            }else{
                let bleArray:[String] = [String]()
                return bleArray
            }
        }
        set{
            
        }
       
    }
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
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.bleUsedArray.count > 0{
            return 2
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return bleUsedArray.count != 0 ? bleUsedArray.count : wifiBLEArray.count
        }else{
            return wifiBLEArray.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            if bleUsedArray.count != 0{
                cell.backgroundColor = UIColor.init(argb: 0x0f5f5f5)
            }else{
                cell.backgroundColor = UIColor.white
            }
        }else{
            cell.backgroundColor = UIColor.white
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.zero)
        let label = UILabel.init(frame: CGRect.init(x: MarginsWidth, y: 0, width: __kWidth - MarginsWidth*2, height: 44))
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = LightGrayColor
        if section == 0{
            if bleUsedArray.count != 0{
                label.text = LocalizedString(forKey: "历史记录")
                headerView.backgroundColor = UIColor.init(argb: 0x0f5f5f5)
            }else{
                label.text = LocalizedString(forKey: "搜索到")
                headerView.backgroundColor = UIColor.white
            }
        }else{
            label.text = LocalizedString(forKey: "搜索到")
            headerView.backgroundColor = UIColor.white
        }
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorStyle = .none
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifer, for: indexPath)
        cell.accessoryType = .none
        cell.contentView.removeAllSubviews()
        var string = ""
        if indexPath.section == 0{
            if bleUsedArray.count != 0{
               string = bleUsedArray[indexPath.row]
            }else{
                string = wifiBLEArray[indexPath.row]
            }
        }else{
             string = wifiBLEArray[indexPath.row]
        }
        cell.tintColor = COR1
        if let essid = self.infoModel?.net?.networkInterface?.essid{
            if string == essid{
                cell.accessoryType = .checkmark
            }
        }
        let label = UILabel.init(frame: CGRect(x: 24 + 12, y: 0, width:__kWidth - MarginsWidth*2 - 24 + 12 , height: 44))
        label.textColor = DarkGrayColor
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.text = string
        cell.contentView.addSubview(label)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var string = ""
        if indexPath.section == 0{
            if bleUsedArray.count != 0{
                string = bleUsedArray[indexPath.row]
            }else{
                string = wifiBLEArray[indexPath.row]
            }
        }else{
            string = wifiBLEArray[indexPath.row]
        }
        self.networkNameTextFiled.text = string
        if let rightView = networkNameTextFiled.rightView as? RightImageView{
             self.spreadIn(rightView: rightView)
        }
    }
}


extension ConfigNetworkViewController:LLBlueToothDelegate{
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
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if #available(iOS 10.0, *) {
            switch central.state {
                
            case CBManagerState.poweredOn:
                print("蓝牙打开")
                self.seekNewDeviceState = .searching
                
            case CBManagerState.unauthorized:
                print("没有蓝牙功能")
                
            case CBManagerState.poweredOff:
                print("蓝牙关闭")
                self.seekNewDeviceState = .bleNotOpen
                
            default:
                print("未知状态")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if(error != nil){
            return
        }
    }
    
    func peripheralCharacteristicDidUpdateValue(deviceBLEModels: [DeviceBLEModel]?) {
        if let devices = deviceBLEModels{
            dataSource = devices
            for model in devices{
                if let currentStationId = AppUserService.currentUser?.stationId, let stationId = model.stationId {
                    if currentStationId.contains(stationId){
                        deviceModel = model
                    }
                }else if let currentStationId = self.user?.stationId,let stationId = model.stationId{
                    if currentStationId.contains(stationId){
                        deviceModel = model
                    }
                }
            }
            self.seekNewDeviceState = .found
        }
    }
    
    //获取对方蓝牙发送的数据
    func peripheralStationSPSCharacteristicDidUpdateValue(data:Data){
        if let string = String.init(data: data, encoding: String.Encoding.utf8){
            wifiBLEDataArray.append(string)
            let bleString = wifiBLEDataArray.joined()
            guard let bleData = bleString.data(using: String.Encoding.utf8) else{
                return
            }
            
            if bleString.contains(find: "[]"){
                 ActivityIndicator.stopActivity(in: self.wifiTabelView)
            }
            
            if bleString.contains(find: "[") && bleString.contains(find: "]"){
                ActivityIndicator.stopActivity(in: self.wifiTabelView)
            }
            
            if bleString.contains(find: "{") && bleString.contains(find: "}"){
                ActivityIndicator.stopActivity(in: self.wifiTabelView)
                if let wifiDic =  dataToNSDictionary(data: bleData){
                    if wifiDic.count == 0{
                        SVProgressHUD.dismiss()
                        wifiBLEDataArray.removeAll()
                        nextButton.isHidden = false
                    }
                    
                    if bleString.contains(find: "error"){
                        wifiBLEDataArray.removeAll()
                        ActivityIndicator.stopActivity(in: self.wifiTabelView)
                        Message.message(text: "error")
                        SVProgressHUD.dismiss()
                        if nextButton.isHidden {
                            nextButton.isHidden = false
                        }
                        return
                    }
                   
                    if let wifiArray = wifiDic["data"] as? Array<String>{
                        self.wifiBLEArray = wifiArray
                        wifiBLEDataArray.removeAll()
                        SVProgressHUD.dismiss()
                        return
                    }
                    
                    if let data = wifiDic["data"] as? NSDictionary{
                         SVProgressHUD.dismiss()
                        if state == .change{
                            SVProgressHUD.setDefaultStyle(.dark)
                            SVProgressHUD.showSuccess(withStatus: LocalizedString(forKey: "Wi-Fi切换成功"))
                            self.navigationController?.popViewController(animated: true)
                            return
                        }
                        if let ipString = data["ip"] as? String{
                            if nextButton.isHidden {
                                nextButton.isHidden = false
                            }
                            self.stationEncryptedAction(ipString: ipString)
                            wifiBLEDataArray.removeAll()
                        }
                        if let ssid = self.networkNameTextFiled.text{
                            bleUsedArray.insert(ssid, at: 0)
                            var usedBles:[String] = [String]()
                            if bleUsedArray.count > 3{
                               usedBles = Array(bleUsedArray.prefix(3))
                            }else{
                                usedBles = bleUsedArray
                            }
                            if let userId = AppUserService.currentUser?.uuid{
                                userDefaults.set(usedBles, forKey: "\(kBLEUsedKey)_\(userId)")
                                userDefaults.synchronize()
                            }else if let userId = self.user?.uuid{
                                userDefaults.set(usedBles, forKey: "\(kBLEUsedKey)_\(userId)")
                                userDefaults.synchronize()
                            }
                        }
                    }
                }else{
                    SVProgressHUD.dismiss()
                     wifiBLEDataArray.removeAll()
                     Message.message(text: "error")
                }
            }
            
            if bleString.contains(find: "error"){
                wifiBLEDataArray.removeAll()
                SVProgressHUD.dismiss()
                ActivityIndicator.stopActivity(in: self.wifiTabelView)
                Message.message(text: "error")
            }
        }
    }
}

