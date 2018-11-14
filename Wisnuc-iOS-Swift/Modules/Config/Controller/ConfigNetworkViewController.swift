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
        defaultNotificationCenter().addObserver(self, selector: #selector(progressHUDDisappear(_:)), name: NSNotification.Name.SVProgressHUDWillDisappear, object: nil)
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
    
    func spreadOut(rightView:RightImageView?){
        rightView?.isSelect = true
        rightView?.image = UIImage.init(named: "down_arrow_gray.png")
        let param = ["action":"scan"]
        self.sendData(param)
        self.tableViewContainerView.isHidden = false
        ActivityIndicator.startActivityIndicatorAnimation(in: wifiTabelView)
    }
    
    func spreadIn(rightView:RightImageView?){
         rightView?.isSelect = false
        rightView?.image = UIImage.init(named: "up_arrow_gray.png")
        self.tableViewContainerView.isHidden = true
        ActivityIndicator.stopActivity(in: self.wifiTabelView)
        wifiBLEArray.removeAll()
        wifiBLEDataArray.removeAll()
    }
    
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
//            usleep(20)
            }
        }
    }
    
    func stationEncryptedAction(ipString:String){
        ActivityIndicator.startActivityIndicatorAnimation()
        AppNetworkService.networkState = .normal
        BindStationAPI.init().startRequestJSONCompletionHandler { [weak self] (response) in
             ActivityIndicator.stopActivityIndicatorAnimation()
            if let error = response.error{
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
                       self?.stationBindAction(ipString: ipString, encryptedString:encryptedString)
                    }
                }
            }
        }
    }
    
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
        guard let token = AppUserService.currentUser?.cloudToken else {
            ActivityIndicator.stopActivityIndicatorAnimation()
            Message.message(text: LocalizedString(forKey:"error:No token"))
            return
        }

        self.getStations(token:token) { [weak self](error, models) in
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
    
    func loginAction(userId:String,model:StationsInfoModel){
        ActivityIndicator.startActivityIndicatorAnimation()
        if let user = AppUserService.user(uuid: userId){
            AppService.sharedInstance().loginAction(stationModel: model, orginTokenUser: user) { (error, userData) in
                ActivityIndicator.stopActivityIndicatorAnimation()
                if error == nil && userData != nil{
                    AppUserService.isUserLogin = true
                    AppUserService.isStationSelected = true
                    AppUserService.setCurrentUser(userData)
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
            //
        }else{
//            AppUserService.logoutUser()
            Message.message(text: ErrorLocalizedDescription.Login.NoCurrentUser, duration: 2.0)
            ActivityIndicator.stopActivityIndicatorAnimation()
        }
    }
    
    func getStations(token:String?,closure: @escaping (Error?,[StationsInfoModel]?) -> Void){
        let requset = GetStationsAPI.init(token: token ?? "")
        requset.startRequestJSONCompletionHandler({ (response) in
            ActivityIndicator.stopActivityIndicatorAnimation()
            if response.error == nil{
                if response.result.value != nil {
                    let rootDic = response.result.value as! NSDictionary
                    //                    print(rootDic)
                    let code = rootDic["code"] as! NSNumber
                    let message = rootDic["message"] as! NSString
                    if code.intValue != 1 && code.intValue > 200 {
                        return  closure(LoginError.init(code: Int(code.int64Value), kind: LoginError.ErrorKind.LoginRequestError, localizedDescription: message as String), nil)
                    }
                    if let dataDic = rootDic["data"] as? NSDictionary{
                        var resultArray:[StationsInfoModel] = Array.init()
                        if let ownStations =  dataDic["ownStations"] as? [NSDictionary]{
                            var ownStationArray:[StationsInfoModel] = Array.init()
                            for value in ownStations{
                                do {
                                    if let data =  jsonToData(jsonDic: value){
                                        var model = try JSONDecoder().decode(StationsInfoModel.self, from:  data)
                                        model.isShareStation = false
                                        ownStationArray.append(model)
                                    }
                                }catch{
                                    return  closure(BaseError(localizedDescription: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail, code: ErrorCode.JsonModel.SwitchTOModelFail),nil)
                                }
                            }
                            resultArray.append(contentsOf: ownStationArray)
                        }
                        if let sharedStations =  dataDic["sharedStations"] as? [NSDictionary]{
                            var sharedStationArray:[StationsInfoModel] = Array.init()
                            for value in sharedStations{
                                do {
                                    if let data =  jsonToData(jsonDic: value){
                                        var model = try JSONDecoder().decode(StationsInfoModel.self, from:  data)
                                        model.isShareStation = true
                                        sharedStationArray.append(model)
                                    }
                                }catch{
                                    return  closure(BaseError(localizedDescription: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail, code: ErrorCode.JsonModel.SwitchTOModelFail),nil)
                                }
                            }
                            resultArray.append(contentsOf:sharedStationArray)
                        }
                        return closure(nil,resultArray)
                    }
                }
            }else{
                return closure(response.error,nil)
            }
        })
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
//        DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 3) {
//            DispatchQueue.main.async {
//                 SVProgressHUD.dismiss()
//
//            }
//        }
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
        let time = SVProgressHUD.displayDuration(for: string)
        if wifiBLEDataArray.count == 0{
//            Message.message(text: LocalizedString(forKey: "Wi-Fi连接失败"))
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
        if let rightView = networkNameTextFiled.rightView as? RightImageView{
             self.spreadIn(rightView: rightView)
        }
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
         SVProgressHUD.dismiss()
        if nextButton.isHidden {
            nextButton.isHidden = false
        }
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
//                    if let error = wifiDic["error"] as? NSDictionary{
//                        wifiBLEDataArray.removeAll()
//                        Message.message(text: "error:\(error)")
//                        return
//                    }
                    if wifiDic.count == 0{
                        wifiBLEDataArray.removeAll()
                        Message.message(text: "error")
                    }
                    
                    if bleString.contains(find: "error"){
                        wifiBLEDataArray.removeAll()
                        ActivityIndicator.stopActivity(in: self.wifiTabelView)
                        Message.message(text: "error")
                        return
                    }
                   
                    if let wifiArray = wifiDic["data"] as? Array<String>{
                        self.wifiBLEArray = wifiArray
                        wifiBLEDataArray.removeAll()
                        return
                    }
                    
                    if let data = wifiDic["data"] as? NSDictionary{
                        if let ipString = data["ip"] as? String{
                            self.stationEncryptedAction(ipString: ipString)
                            wifiBLEDataArray.removeAll()
                        }
                    }
                }else{
                     wifiBLEDataArray.removeAll()
                     Message.message(text: "error")
                }
            }
            
            if bleString.contains(find: "error"){
                 wifiBLEDataArray.removeAll()
                ActivityIndicator.stopActivity(in: self.wifiTabelView)
                Message.message(text: "error")
            }
        }
    }
}

