 //
//  LoginViewController.swift
//  FruitMix-Swift
//
//  Created by wisnuc-imac on 2018/3/16.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import SnapKit
import MaterialComponents
import HandyJSON
import Alamofire

 enum LoginState:Int{
    case wechat = 0
    case token
    case chooseStation
 }
 
 struct LoginError: Error,Equatable{
    enum ErrorKind {
        case LoginSucess
        case LoginPasswordWrong
        case LoginNoBindDevice
        case LoginNoOnlineDevice
        case LoginNoBindUser
        case LoginRequestError
    }
    
    let code: Int
    let kind: ErrorKind
    let localizedDescription: String
 }

private let ButtonHeight:CGFloat = 36
private let UserImageViewWidth:CGFloat = 114
private let ImageViewBorderColor:CGColor = UIColor.init(red: 41/255.0, green: 165/255.0, blue: 151/255.0, alpha: 1).cgColor
private let StationViewScale:CGFloat = __kHeight * 0.36
private let imageViewSize = CGSize(width: UserImageViewWidth, height: UserImageViewWidth)

class LoginViewController: UIViewController {
    var commonLoginButon:UIButton!
    var userName:String?
    var cloudLoginArray:Array<CloadLoginUserRemotModel>?
    var loginModel:CloudLoginModel?
    var logintype:LoginState?{
        didSet{
            print("did set ")
            switch self.logintype {
            case .wechat?:
                actionForWechatLoginType()
            case .token?:
                actionForTokenLoginType()
            case .chooseStation?:
                actionForStationType()
            default:
                break
            }
        }
        
        willSet{
            print("will set ")
        }
        
    }
    
    init(_ type:LoginState) {
        super.init(nibName: nil, bundle: nil)
        cloudLoginArray = Array.init()
        setSelfType(type)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = COR1
        self.view.addSubview(self.agreementButton)
        self.view.addSubview(self.wisnucLabel)
        self.view.addSubview(self.wisnucImageView)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        
    }
    
    func setCommonButtonType() {
        switch self.logintype {
        case .wechat?:
            self.commonLoginButon = self.weChatButton
        case .token?:
            self.commonLoginButon = self.loginButton
        default:
            break
        }
    }
    
    func setUpFrame() {
        let size = CGSize(width: Int(labelWidthFrom(title: self.wisnucLabel.text!, font: self.wisnucLabel.font!) + 20), height: Int(labelHeightFrom(title: self.wisnucLabel.text!, font: self.wisnucLabel.font!)))
        self.wisnucLabel.frame = CGRect(origin: CGPoint(x: (__kWidth - size.width)/2, y: commonLoginButon.frame.minY - 50), size:size)
        self.wisnucImageView.frame = CGRect(origin: CGPoint(x: (__kWidth - imageViewSize.width)/2, y: wisnucLabel.frame.minY - MarginsWidth - imageViewSize.width), size:imageViewSize)
    }
    
    func  setSelfType(_ type:LoginState){
        self.logintype = type
    }
    
    
    @objc func agreementButtonClick () {
        let messageString = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur " +
            "ultricies diam libero, eget porta arcu feugiat sit amet. Maecenas placerat felis sed risus " +
            "maximus tempus. Integer feugiat, augue in pellentesque dictum, justo erat ultricies leo, " +
            "quis eleifend nisi eros dictum mi. In finibus vulputate eros, in luctus diam auctor in. " +
            "Aliquam fringilla neque at augue dictum iaculis. Etiam ac pellentesque lectus. Aenean " +
            "vestibulum, tortor nec cursus euismod, lectus tortor rhoncus massa, eu interdum lectus urna " +
            "ut nulla. Phasellus elementum lorem sit amet sapien dictum, vel cursus est semper. Aenean " +
            "vel turpis maximus, accumsan dui quis, cursus turpis. Nunc a tincidunt nunc, ut tempus " +
            "libero. Morbi ut orci laoreet, luctus neque nec, rhoncus enim. Cras dui erat, blandit ac " +
            "malesuada vitae, fringilla ac ante. Nullam dui diam, condimentum vitae mi et, dictum " +
        "euismod libero. Aliquam commodo urna vitae massa convallis aliquet."
        
        let materialAlertController = MDCAlertController(title: "用户协议", message: messageString)
    
        let action = MDCAlertAction(title:"OK") { (_) in print("OK") }

        materialAlertController.addAction(action)
        
        self.present(materialAlertController, animated: true, completion: nil)
    }
    
    func weChatCallBackRespCode(code:String){
        ActivityIndicator.startActivityIndicatorAnimation()
        CloudLoginAPI.init(code: code).startRequestDataCompletionHandler { [weak self] (responseData) in
            if responseData.error == nil{
                do {
                    let cloudLoginModel = try JSONDecoder().decode(CloudLoginModel.self, from:    responseData.data!)
                    print(String(data: responseData.data!, encoding: String.Encoding.utf8) as String? ?? "2222")
                    if (cloudLoginModel.data?.token != nil) && (cloudLoginModel.data?.token?.count)!>0 {
                        self?.logintype = .token
                        let image = UIImage.init(named: "logo")
                        self?.wisnucImageView.was_setCircleImage(withUrlString:cloudLoginModel.data?.user?.avatarUrl ?? "" , placeholder: image!)
                        DispatchQueue.main.async {
                            self?.wisnucLabel.text = cloudLoginModel.data?.user?.nickName ?? "WISNUC"
                        }
                        let user = AppUserService.createUser(uuid: (cloudLoginModel.data?.user?.id)!)
                        user.cloudToken = cloudLoginModel.data?.token!
                        if cloudLoginModel.data?.user?.avatarUrl != nil{
                            user.avaterURL = cloudLoginModel.data?.user?.avatarUrl!
                        }
                        
                        if cloudLoginModel.data?.user?.nickName != nil{
                            user.userName = cloudLoginModel.data?.user?.nickName!
                        }   

                        AppUserService.setCurrentUser(user)
                        AppUserService.synchronizedCurrentUser()
                        ActivityIndicator.stopActivityIndicatorAnimation()
                    }
                } catch {
                    // 异常处理
                }
            }else{
                ActivityIndicator.stopActivityIndicatorAnimation()
            }
        }
    }
    
    func findStation(uuid:String?,token:String?, closure: @escaping (Error?,NSArray?) -> Void){
        if uuid == nil || token == nil{
            return
        }
        
        CloudGetStationsAPI.init(guid: (uuid)!, token: (token)!).startRequestJSONCompletionHandler { (response) in
            if response.error == nil{
                if response.result.value != nil {
                    let rootDic = response.result.value as! NSDictionary
//                    print(rootDic)
                    let code = rootDic["code"] as! NSNumber
                    let message = rootDic["message"] as! NSString
                    if code.intValue < 1 && code.intValue > 200 {
                        return  closure(LoginError.init(code: Int(code.int64Value), kind: LoginError.ErrorKind.LoginRequestError, localizedDescription: message as String), nil)
                    }
                    let dataArray = rootDic["data"] as! NSArray
                    if dataArray.count == 0{
                      return  closure(LoginError.init(code: 50001, kind: LoginError.ErrorKind.LoginNoBindDevice, localizedDescription: LocalizedString(forKey: "no station had bind")), nil)
                    }else{
                            return closure(nil,dataArray)
                    }
                }
            }else{
                print(response.error ?? "error")
                return closure(response.error,nil)
            }
        }
    }
    
    func findUser(stationDictionary:NSDictionary,uuid:String?,token:String? ,closure: @escaping (Error?,CloadLoginUserRemotModel?) -> Void){
        let stationId = stationDictionary.value(forKey: "id") as! String
        let isOnline = stationDictionary.value(forKey: "isOnline") as! Bool
        
        if isOnline {
            GetUsersAPI.init(stationId: stationId, token: token!).startRequestJSONCompletionHandler { (response) in
                if response.error == nil{
                    let rootDic = response.value as! NSDictionary
                    let dataArray = rootDic.value(forKey: "data") as! NSArray
                    if dataArray.count == 0{
                        return closure(LoginError.init(code: 50003, kind: LoginError.ErrorKind.LoginNoBindUser, localizedDescription: LocalizedString(forKey: "No this User")), nil)
                    }
                    var mutableDic:NSMutableDictionary?
                    dataArray.enumerateObjects({ (obj, idx, stop) in
                        let dic:NSDictionary = obj as! NSDictionary
                        
                        if !(dic.value(forKey: "global") as AnyObject).isKind(of: NSNull.self){
                            let globalDic:NSDictionary = dic.value(forKey: "global") as! NSDictionary
                            let idString = globalDic.value(forKey: "id") as! String
                            if uuid == idString{
                                mutableDic = NSMutableDictionary.init(dictionary: dic)
                                mutableDic?.addEntries(from: stationDictionary as! [AnyHashable : Any])
                                if let userModel = CloadLoginUserRemotModel.deserialize(from: mutableDic){
                                    let lanArray = stationDictionary.value(forKey: "LANIP") as! NSArray
                                    if lanArray.count>0{
                                        userModel.LANIP = lanArray.firstObject as? String
                                    }
                                    return closure(nil,userModel)
                                }
                            }
                        }
                    })
                    
                }else{
                    return closure(response.error,nil)
                }
            }
        }else{
             var mutableDic:NSMutableDictionary?
             mutableDic = NSMutableDictionary.init(dictionary: stationDictionary)
            if let userModel = CloadLoginUserRemotModel.deserialize(from: mutableDic){
                let lanArray = stationDictionary.value(forKey: "LANIP") as! NSArray
                if lanArray.count>0{
                    userModel.LANIP = lanArray.firstObject as? String
                }
                return closure(nil,userModel)
            }
        }
    }
    
    func loginAction(){
        ActivityIndicator.startActivityIndicatorAnimation()
        let uuid = userDefaults.object(forKey: kCurrentUserUUID) as? String
        if uuid == nil {
            Message.message(text: LocalizedString(forKey: "no uuid"))
            return
        }
        let user = AppUserService.user(uuid:uuid!)
        if user != nil {
            self.findStation(uuid: user?.uuid, token: user?.cloudToken) { [weak self] (error, devieceArray) in
                if(error != nil) {
                    ActivityIndicator.stopActivityIndicatorAnimation()
                    switch error{
                    case is LoginError :
                        let loginError = error as! LoginError
                        if loginError.kind == LoginError.ErrorKind.LoginNoBindDevice || loginError.kind == LoginError.ErrorKind.LoginNoOnlineDevice || loginError.kind == LoginError.ErrorKind.LoginRequestError {
                            Message.message(text: LocalizedString(forKey: loginError.localizedDescription), duration:2.0)
                        }else  {
                            Message.message(text: LocalizedString(forKey:"\(String(describing: (error?.localizedDescription)!))"),duration:2.0)
                        }
                    default:
                        Message.message(text: LocalizedString(forKey:"\(String(describing: (error?.localizedDescription)!))"),duration:2.0)
                    }
                }else {
                    devieceArray?.enumerateObjects({ (obj, idx, stop) in
                        let dic = obj as! NSDictionary
                        self?.findUser(stationDictionary: dic, uuid: uuid, token: user?.cloudToken, closure: { (userError, userModel) in
                            if userError == nil{
                                if (dic.value(forKey: "isOnline") != nil){
                                    if (dic.value(forKey: "isOnline") as! Bool){
                                        userModel?.state = StationButtonType.normal.rawValue
                                    }else{
                                        userModel?.state = StationButtonType.offline.rawValue
                                    }
                                }
                                self?.cloudLoginArray?.append(userModel!)
                                self?.cloudLoginArray?.sort(by: {$0.isOnline! && !$1.isOnline!})
                                self?.stationView.stationArray = self?.cloudLoginArray
                            }else{
                                switch userError{
                                case is LoginError :
                                    let loginError = userError as! LoginError
                                    if  loginError.kind == LoginError.ErrorKind.LoginNoBindUser{
                                        Message.message(text: LocalizedString(forKey: loginError.localizedDescription),duration:2.0)
                                    }
                                default:
                                    Message.message(text: LocalizedString(forKey:"\(String(describing: (userError?.localizedDescription)!))"),duration:2.0)
                                }
                            }
                            ActivityIndicator.stopActivityIndicatorAnimation()
                        })
                    })
                }
            }
        }
    }
    
    
    @objc func weChatViewButtonClick(){
          checkNetwork()
    }
    
    @objc func  loginButtonClick(){
        self.setSelfType(.chooseStation)
        self.loginAction()
    }
    
    @objc func imageViewTap(_ sender:UIGestureRecognizer){
        let logoutVC = LogOutViewController.init()
        self.navigationController?.pushViewController(logoutVC, animated: true)
    }
    
    func checkNetwork(){
        let networkStatus = NetworkStatus()
        networkStatus.getNetworkStatus { (status) in
            switch status {
            case .Disconnected:
                Message.message(text: "无法连接服务器，请检查网络")
                return
            default:
                self.checkWechat()
                break
            }
        }
    }
    
    func checkWechat() {
        if (WXApi.isWXAppInstalled()) {
            let req = SendAuthReq.init()
            req.scope = "snsapi_userinfo"
            req.state = "App"
            WXApi.send(req)
        }else{
            Message.message(text: "请先安装微信")
        }
        
//       ActivityIndicator.startActivityIndicatorAnimation()
//        DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 4.0) {
//            print("after!")
//            ActivityIndicator.stopActivityIndicatorAnimation()
//            DispatchQueue.main.async {
//                self.logintype = .token
//            }
//        }
    }
    
    func actionForStationType() {
        if cloudLoginArray != nil{
            cloudLoginArray?.removeAll()
        }
        view.addSubview(self.stationView)
        ViewTools.automaticallyAdjustsScrollView(scrollView: self.stationView.stationScrollView, viewController: self)
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.loginButton.alpha = 0
            self.agreementButton.alpha = 0
            self.stationView.frame.origin.y = StationViewScale
            self.wisnucImageView.center.y = StationViewScale/2
            self.wisnucLabel.frame.origin.y = self.wisnucImageView.frame.maxY + MarginsWidth
        }) { (completion) in
            self.loginButton.isHidden = true
            self.agreementButton.isHidden = true
        }
    }
    
    func actionForWechatLoginType() {
        DispatchQueue.main.async {
            if self.commonLoginButon != nil{
                self.loginButton.removeFromSuperview()
            }
            self.commonLoginButon = self.weChatButton
            self.view.addSubview(self.commonLoginButon!)
            self.setUpFrame()
            self.wisnucImageView.layer.borderColor = UIColor.clear.cgColor
            self.wisnucImageView.image = UIImage.init(named: "logo")
        }
        
        if cloudLoginArray != nil{
            cloudLoginArray?.removeAll()
        }
    }
    
    
    func actionForTokenLoginType() {
        if cloudLoginArray != nil{
            cloudLoginArray?.removeAll()
        }
        DispatchQueue.main.async {
            if self.commonLoginButon != nil{
                self.weChatButton.removeFromSuperview()
            }
            self.commonLoginButon = self.loginButton
            self.view.addSubview(self.commonLoginButon!)
            if self.stationView.origin.y == __kHeight{
                self.setUpFrame()
            }else{
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
//                    if self.stationView.origin.y != __kHeight{
                        self.setUpFrame()
                        self.stationView.origin.y = __kHeight
                        self.loginButton.alpha = 1
                        self.agreementButton.alpha = 1
//                    }
                }) { (completion) in
                    self.loginButton.isHidden = false
                    self.agreementButton.isHidden = false
                }
            }
           
            let image = UIImage.init(named: "logo")
            let uuid = userDefaults.object(forKey: kCurrentUserUUID) as? String
            if uuid != nil && uuid?.count != 0 {
                let user = AppUserService.user(uuid: uuid!)
                self.wisnucImageView.was_setCircleImage(withUrlString:user?.avaterURL ?? "" , placeholder: image!)
                self.userName = user?.userName
            }
            self.wisnucLabel.text = self.userName ?? "登录名"
            self.wisnucImageView.layer.borderColor = ImageViewBorderColor
            self.wisnucImageView.layer.masksToBounds = true
            self.wisnucImageView.layer.borderWidth = 8
            self.wisnucImageView.layer.cornerRadius = UserImageViewWidth/2
        }
    }
    
    lazy var stationView: MyStationView = {
        let view = MyStationView(frame: CGRect(x: 0, y: __kHeight, width: __kWidth, height: __kHeight - __kHeight * 0.36))
        view.delegate = self
        return view
    }()
    
    lazy var agreementButton: UIView = {
        let bgView = UIView.init(frame: CGRect(x: 0, y: __kHeight - 48, width: __kWidth, height: 48))
        let button = UIButton.init(frame: CGRect(x: 0, y: 0, width: bgView.bounds.width, height: 13))
        
        let str = "用户协议"
//        let str = NSMutableAttributedString.init(string:"用户协议")
//        str.addAttribute(NSAttributedStringKey.underlineStyle, value: NSNumber(integerLiteral: NSUnderlineStyle.styleSingle.rawValue), range: NSRange(location: 0, length: str.length))
//        str.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: str.length))
//        str.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 13), range: NSRange(location: 0, length: str.length))
//        button.setAttributedTitle(str, for: UIControlState.normal)
  
        button.setTitle(str, for: UIControlState.normal)
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        button.addTarget(self, action: #selector(agreementButtonClick), for: UIControlEvents.touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        bgView.addSubview(button)
 
        let widthSize = labelWidthFrom(title: str, font:(button.titleLabel?.font)!)

        
        let underline = UIView.init(frame: CGRect(origin: CGPoint(x:button.center.x - widthSize/2  , y: button.center.y + button.frame.size.height/2 + 3), size: CGSize(width: Int(widthSize), height: 1)))
        underline.backgroundColor = UIColor.white
        
        bgView.addSubview(underline)
        return bgView
    }()
    
    lazy var weChatButton: MDBaseButton = {
        let innerWechatView = MDBaseButton.init(frame: CGRect(x: MarginsWidth, y: self.view.frame.size.height/2 + 50, width: __kWidth - MarginsWidth * 2, height: ButtonHeight))
        innerWechatView.backgroundColor = WechatLoginButtonColor
        innerWechatView.layer.cornerRadius = 2.0
        
        let wechatImage = UIImage.init(named: "wechat_icon")
        let wechatImageView = UIImageView.init(image: wechatImage)
        innerWechatView.addSubview(wechatImageView)
        wechatImageView.snp.makeConstraints({ (make) in
            make.centerX.equalTo(innerWechatView.snp.centerX).offset(-30)
            make.centerY.equalTo(innerWechatView.snp.centerY)
            make.size.equalTo((wechatImage?.size)!)
        })
        
        let label = UILabel.init();
        label.text = LocalizedString(forKey: "wechat_login")
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.white
        label.alpha = 0.87
        
        innerWechatView.addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.left.equalTo(wechatImageView.snp.right).offset(8)
            make.centerY.equalTo(innerWechatView.snp.centerY)
            make.size.equalTo(CGSize(width: 100, height: labelHeightFrom(title: label.text!, font: label.font!)))
        }
        
        innerWechatView .addTarget(self, action: #selector(weChatViewButtonClick), for: UIControlEvents.touchUpInside)
        return innerWechatView
    }()
    
    lazy var loginButton: MDBaseButton = {
        let buttonTitleString = LocalizedString(forKey: "login")
        let buttonTitleFont = MiddleTitleFont
        let button = MDBaseButton.init(frame: CGRect(x: 0, y: 0, width: Int(labelWidthFrom(title: buttonTitleString, font: buttonTitleFont)) + 40, height: Int(ButtonHeight)))
        button.setBackgroundColor(UIColor.clear)
        button.setBorderColor(UIColor.colorFromRGB(rgbValue: 0x0017f6f), for: UIControlState.normal)
        button.setBorderWidth(1.0, for: UIControlState.normal)
        button.setTitleFont(buttonTitleFont, for: UIControlState.normal)
        button.center = CGPoint(x: view.center.x, y: view.center.y + 50 + ButtonHeight/2)
        button.layer.cornerRadius = 2.0
//        button.layer.borderWidth = 1
//        button.layer.borderColor = UIColor.colorFromRGB(rgbValue: 0x0017f6f).cgColor
        button.setTitle(buttonTitleString, for: UIControlState.normal)
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        button.titleLabel?.font = buttonTitleFont
        button .addTarget(self, action: #selector(loginButtonClick), for: UIControlEvents.touchUpInside)
        return button
    }()

	lazy var wisnucImageView:UIImageView = {
        let imageView = UIImageView.init()
        imageView.isUserInteractionEnabled = true
        let imageViewTapGesture = UITapGestureRecognizer.init(target: self, action: #selector(imageViewTap(_ :)))
        imageView.addGestureRecognizer(imageViewTapGesture)
        return imageView
    }()
    
    lazy var wisnucLabel:UILabel = {
        let label = UILabel.init()
        let string = "WISNUC"
        let font = UIFont.boldSystemFont(ofSize: 15)
        label.font = font
        label.textColor = UIColor.white
        label.text = string
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - Delegate
 extension LoginViewController:StationViewDelegate{
    func stationViewSwipeAction() {
        NetEngine.sharedInstance.cancleAllRequest()
        self.logintype = .token
    }
    
    func stationViewTapAction(_ sender: MyStationTapGestureRecognizer) {
        switch sender.stationButtonType {
        case .checking?:
            let titleString = LocalizedString(forKey: "station_checking")
            let messageString = "\(String(describing: sender.stationName!)) 未通过审核"
            Alert.alert(title: titleString, message: messageString)
        case .offline?:
            let titleString = LocalizedString(forKey: "station_offline")
            let messageString = "\(String(describing: sender.stationName!)) 已离线"
            Alert.alert(title: titleString, message: messageString)
        case .local?:
            let localNetVC = LocalNetworkLoginViewController.init()
            self.navigationController?.pushViewController(localNetVC, animated: true)
        case .diskError?:
            let diskErrorVC = DiskErrorViewController.init()
            self.present(diskErrorVC, animated: true, completion: {
                
            })
        case .normal?:
            setRootViewController()
        default:
            break
        }
    }
    
    func addStationButtonTap(_ sender: UIButton) {
        let addStationVC = AddStationViewController.init()
        addStationVC.delegate = self
        self.navigationController?.pushViewController(addStationVC, animated: true)
    }
}

extension LoginViewController:AddStationDelegate{
    func addStationFinish(model: CloadLoginUserRemotModel) {
           self.stationView.addStation(model: model)
    }
}

