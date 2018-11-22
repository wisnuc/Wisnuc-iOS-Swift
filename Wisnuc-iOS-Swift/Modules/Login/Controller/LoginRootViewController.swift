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
 import RxSwift
 
 enum LoginState:Int{
    case wechat = 0
    case token
    case chooseStation
 }
 
 private var ButtonHeight:CGFloat = 48
 private let UserImageViewWidth:CGFloat = 114
 public let ImageViewBorderColor:CGColor = UIColor.init(red: 41/255.0, green: 165/255.0, blue: 151/255.0, alpha: 1).cgColor
 private let StationViewScale:CGFloat = __kHeight * 0.36
 private let imageViewSize = CGSize(width: UserImageViewWidth, height: UserImageViewWidth)
 
 class LoginRootViewController: BaseViewController {
//    override func willDealloc() -> Bool {
//        return false
//    }
    var showTab = false
    var commonLoginButon:UIButton!
    var userName:String?
    var disposeBag = DisposeBag()
    var cloudLoginArray:Array<CloadLoginUserRemotModel>?
    var stationArray:Array<StationsInfoModel>?
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
        super.init()
        cloudLoginArray = Array.init()
        setSelfType(type)
    }
    
    override init(style: NavigationStyle) {
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerNotification()
        self.prepareNavigationBar()
        self.view.backgroundColor = COR1
        self.view.addSubview(self.wisnucLabel)
        self.view.addSubview(self.creatNewAccoutButton)
        self.view.addSubview(self.agreementButton)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        defaultNotificationCenter().addObserver(self, selector: #selector(configFinishPre(_:)), name: NSNotification.Name.Config.ConfigFinishPreDismissKey, object: nil)
        defaultNotificationCenter().addObserver(self, selector: #selector(configFinish(_:)), name: NSNotification.Name.Config.ConfigFinishDismissKey, object: nil)
        if showTab {
            self.view.removeAllSubviews()
            self.view.backgroundColor = .white
            self.prepreTabbar()
            self.view.addSubview(tabbar)
            self.tabbar.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
       print("\(className()) deinit")
        defaultNotificationCenter().removeObserver(self)
    }
    
    func prepreTabbar(){
        tabbar.backgroundColor = UIColor.white
        tabbar.setLayerShadow(Gray26Color, offset: CGSize(width: 0, height: -5), radius: 4)
        tabbar.layer.shadowOpacity = 0.37
    }
    
    func prepareNavigationBar(){
        let rightItem = UIBarButtonItem.init(title: LocalizedString(forKey: "登录"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(loginButtonClick))
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func registerNotification(){
//        defaultNotificationCenter()
//            .rx
//            .notification(Notification.Name.Change.LocalLoginDismissNotiKey)
//            .subscribe(onNext: { (noti) in
//                 ActivityIndicator.startActivityIndicatorAnimation()
//                 appDelegate.setRootViewController()
//                 ActivityIndicator.stopActivityIndicatorAnimation()
//            })
//            .disposed(by: disposeBag)
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
        self.wisnucLabel.frame = CGRect(origin: CGPoint(x: MarginsWidth, y: MDCAppNavigationBarHeight + 118), size:size)
        self.weChatButton.frame = CGRect(x: MarginsWidth, y: self.wisnucLabel.bottom + 48, width: __kWidth - MarginsWidth * 2, height: ButtonHeight)
        self.creatNewAccoutButton.frame = CGRect(x: MarginsWidth, y: self.weChatButton.bottom + 16, width: __kWidth - MarginsWidth * 2, height: ButtonHeight)
//        self.wisnucImageView.frame = CGRect(origin: CGPoint(x: (__kWidth - imageViewSize.width)/2, y: wisnucLabel.frame.minY - MarginsWidth - imageViewSize.width), size:imageViewSize)
    }
    
    func  setSelfType(_ type:LoginState){
        self.logintype = type
    }
    
    @objc func configFinish(_ noti:Notification){
        appDelegate.initRootVC()
//        let vc  = UIViewController.init()
//        vc.view.backgroundColor = .white
//        vc.title = "主界面"
//        let navigationController = UINavigationController.init(rootViewController: vc)
//        appDelegate.window?.rootViewController = navigationController
    }
    
    @objc func configFinishPre(_ noti:Notification){
        self.showTab = true
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
        ViewTools.setAlertControllerColor(alertController: materialAlertController)
        let action = MDCAlertAction(title:"OK") { (_) in print("OK") }
        
        materialAlertController.addAction(action)
        
        self.present(materialAlertController, animated: true, completion: nil)
    }
    
    func oldWechatLogin(code:String){
        ActivityIndicator.startActivityIndicatorAnimation()
        CloudLoginAPI.init(code: code).startRequestDataCompletionHandler { [weak self] (responseData) in
            if responseData.error == nil{
                do {
                    let cloudLoginModel = try JSONDecoder().decode(CloudLoginModel.self, from: responseData.data!)
                    print(String(data: responseData.data!, encoding: String.Encoding.utf8) as String? ?? "2222")
                    if (cloudLoginModel.data?.token != nil) && (cloudLoginModel.data?.token?.count)!>0 {
                        let image = UIImage.init(named: "logo")
                        self?.wisnucImageView.was_setCircleImage(withUrlString:cloudLoginModel.data?.user?.avatarUrl ?? "" , placeholder: image!)
                        //                        DispatchQueue.main.async {
                        //                            self?.wisnucLabel.text = cloudLoginModel.data?.user?.nickName ?? "WISNUC"
                        //                        }
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
                        self?.setSelfType(.chooseStation)
                        self?.loginAction()
                    }
                } catch {
                    // 异常处理
                    Message.message(text: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail)
                }
                ActivityIndicator.stopActivityIndicatorAnimation()
            }else{
                ActivityIndicator.stopActivityIndicatorAnimation()
                let responseErrorDic = dataToNSDictionary(data: responseData.data!)
                print(responseErrorDic as Any)
                if let message = responseErrorDic?[kRequestResponseMessageKey] as? String{
                    Message.message(text: message)
                }
            
//                let errorString = String.init(data: responseData, encoding: <#T##String.Encoding#>)
//                String
            }
        }
    }
    
    func wechatSighInAction(code:String){
        ActivityIndicator.startActivityIndicatorAnimation()
        SighInWechatTokenAPI.init(code: code).startRequestDataCompletionHandler { [weak self] (responseData) in
            if responseData.error == nil{
                do {
                    let wechatSighInModel = try JSONDecoder().decode(WechatSighInModel.self, from: responseData.data!)
//                    print(String(data: responseData.data!, encoding: String.Encoding.utf8) as String? ?? "2222")
                    if let user = wechatSighInModel.data?.user{
                        if !user{
                              ActivityIndicator.stopActivityIndicatorAnimation()
                              if let wechatToken = wechatSighInModel.data?.wechat{
                                    ActivityIndicator.stopActivityIndicatorAnimation()
                                    self?.next(.bindPhoneWechat,requestToken: wechatToken)
                              }
                        }else{
                            do {
                                let model = try JSONDecoder().decode(SighInTokenModel.self, from: responseData.data!)
                                    if let token = model.data?.token {
                                        guard let userId = model.data?.id else{
                                            return
                                        }
                                        guard let header = responseData.response?.allHeaderFields else {
                                            return
                                        }
                                        guard let cookie = header["Set-Cookie"] as? String else {
                                            return
                                        }
                                        self?.synchronizedUser(model, cookie)
                                        LoginCommonHelper.instance.stationAction(token: token,userId:userId, viewController: self!)
                                    }
                            } catch {
                                // 异常处理
                                Message.message(text: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail)
                            }
                        }
                    }
                    
                } catch {
                    // 异常处理
                    Message.message(text: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail)
                }
            }else{
                Message.message(text: "error code :\(String(describing: responseData.response?.statusCode ?? -0)) error:\(String(describing: responseData.error?.localizedDescription ?? "未知错误"))")
            }
            ActivityIndicator.stopActivityIndicatorAnimation()
        }
    }
    
    func synchronizedUser(_ model:SighInTokenModel,_ cookie:String){
        let user = AppUserService.createUser(uuid: (model.data?.id)!)
        user.cloudToken = model.data?.token!
        if let avatarUrl = model.data?.avatarUrl{
            user.avaterURL = avatarUrl
        }
        user.cookie = cookie
        
        if let nickName = model.data?.nickName{
            user.nickName = nickName
        }
        
        if let username = model.data?.username{
            user.userName = username
        }
        
        AppUserService.setCurrentUser(user)
        AppUserService.synchronizedCurrentUser()
    }
//
    func weChatCallBackRespCode(code:String){
//            oldWechatLogin(code:code)
        wechatSighInAction(code:code)
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
                    if code.intValue != 1 && code.intValue > 200 {
                        return  closure(LoginError.init(code: Int(code.int64Value), kind: LoginError.ErrorKind.LoginRequestError, localizedDescription: message as String), nil)
                    }
                    let dataArray = rootDic["data"] as! NSArray
                    if dataArray.count == 0{
                        return  closure(LoginError.init(code: ErrorCode.Login.NoBindDevice, kind: LoginError.ErrorKind.LoginNoBindDevice, localizedDescription: LocalizedString(forKey: "no station had bind")), nil)
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
            let queue = DispatchQueue.init(label: "com.backgroundQueue.api", qos: .background, attributes: .concurrent)
            GetUsersAPI.init(stationId: stationId, token: token!).startRequestJSONCompletionHandler(queue) { (response) in
                if response.error == nil{
                    let rootDic = response.value as! NSDictionary
                    if rootDic.value(forKey: "data") is NSDictionary{
                        let dic = rootDic.value(forKey: "data") as! NSDictionary
                        let code = dic["code"] as! NSNumber
                        let message = dic["message"] as! NSString
                        if code.intValue != 1 && code.intValue > 200 {
                            return  closure(LoginError.init(code: Int(code.int64Value), kind: LoginError.ErrorKind.LoginRequestError, localizedDescription: message as String), nil)
                        }
                    }
                    let dataArray = rootDic.value(forKey: "data") as! NSArray
                    if dataArray.count == 0{
                        return closure(LoginError.init(code: ErrorCode.Login.NoUserExist, kind: LoginError.ErrorKind.LoginNoBindUser, localizedDescription: LocalizedString(forKey: "No this User")), nil)
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
                                        userModel.state = StationButtonType.normal.rawValue
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
                  userModel.state = StationButtonType.offline.rawValue
                return closure(nil,userModel)
            }
        }
    }
    
    func loginAction(){
        ActivityIndicator.startActivityIndicatorAnimation()
        let uuid = userDefaults.object(forKey: kCurrentUserUUID) as? String
        if uuid == nil {
            Message.message(text: LocalizedString(forKey: "no uuid"))
            ActivityIndicator.stopActivityIndicatorAnimation()
            return
        }
        let user = AppUserService.user(uuid:uuid!)
        if user != nil {
            self.findStation(uuid: user?.uuid, token: user?.cloudToken) { [weak self] (error, devieceArray) in
                if(error != nil) {
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
                    ActivityIndicator.stopActivityIndicatorAnimation()
                }else {
                    let dispatchGroup = DispatchGroup.init()
                    devieceArray?.enumerateObjects({ (obj, idx, stop) in
                        dispatchGroup.enter()
                        let dic = obj as! NSDictionary
                        self?.findUser(stationDictionary: dic, uuid: uuid, token: user?.cloudToken, closure: { [weak self] (userError, userModel) in
                            ActivityIndicator.stopActivityIndicatorAnimation()
                            if userError == nil{
                                self?.cloudLoginArray?.append(userModel!)
                            }else{
                                switch userError{
                                case is LoginError :
                                    let loginError = userError as! LoginError
                                    if  loginError.kind == LoginError.ErrorKind.LoginNoBindUser{
                                        Message.message(text: LocalizedString(forKey: loginError.localizedDescription),duration:2.0)
                                    }else{
                                        Message.message(text: LocalizedString(forKey:"\(String(describing: loginError.localizedDescription))"),duration:2.0)
                                    }
                                default:
                                    Message.message(text: LocalizedString(forKey:"\(String(describing: (userError?.localizedDescription)!))"),duration:2.0)
                                }
                            }
                            dispatchGroup.leave()
                        })
                    })
                    dispatchGroup.notify(queue: DispatchQueue.main) {
                        print("队列执行完毕")
                        self?.cloudLoginArray?.sort(by: {$0.isOnline! && !$1.isOnline!})
                        
                        self?.stationView.stationArray = self?.cloudLoginArray
                    }
                }
            }
        }
    }
    
    func normalLoginAction(model:CloadLoginUserRemotModel){
        ActivityIndicator.startActivityIndicatorAnimation()
        if userDefaults.object(forKey: kCurrentUserUUID) == nil {
            Message.message(text: ErrorLocalizedDescription.Login.NoCurrentUser, duration: 2.0)
            self.logintype = .wechat
            ActivityIndicator.stopActivityIndicatorAnimation()
            return
        }

        if let originUser = AppUserService.user(uuid: userDefaults.object(forKey: kCurrentUserUUID) as! String){
            AppService.sharedInstance().loginAction(model: model, orginTokenUser:originUser) { (error, user) in
                if error == nil && user != nil{
                    AppUserService.setCurrentUser(user)
                    AppUserService.synchronizedCurrentUser()
                    appDelegate.initRootVC()
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
                        AppUserService.logoutUser()
                    }
                }
            }
             ActivityIndicator.stopActivityIndicatorAnimation()
        }else{
           Message.message(text: ErrorLocalizedDescription.Login.NoCurrentUser, duration: 2.0)
           self.logintype = .wechat
            ActivityIndicator.stopActivityIndicatorAnimation()
        }
    }
    
    @objc func weChatViewButtonClick(){
        checkNetwork()
    }
    
    @objc func  loginButtonClick(){
        let loginVC = LoginViewController.init(style: NavigationStyle.mainTheme)
        loginVC.delegate = self
        let navigationController = UINavigationController.init(rootViewController: loginVC)
        navigationController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func imageViewTap(_ sender:UIGestureRecognizer){
        if logintype == .wechat {
           return
        }
        var name:String?
        var avatarUrl:String?
        let uuid = userDefaults.object(forKey: kCurrentUserUUID) as? String
        if uuid != nil && uuid?.count != 0 {
            let user = AppUserService.user(uuid: uuid!)
            name = user?.userName
            avatarUrl = user?.avaterURL
        }
        
        let logoutVC = LogOutViewController.init(avatarUrl: avatarUrl, name:name)
        logoutVC.delegate = self
        self.navigationController?.pushViewController(logoutVC, animated: true)
    }

    @objc func creatNewAccoutButton(_ sender:MDBaseButton?){
       next(.bindPhoneNumber)
    }
    
    func next(_ state:LoginNextStepViewControllerState,requestToken:String? = nil){
        let smsCodeType:SendCodeType = .register
        let creatNewAccoutVC = LoginNextStepViewController.init(titleString: LocalizedString(forKey: "绑定手机号"), detailTitleString: LocalizedString(forKey: "手机号码是您忘记密码时，找回面的唯一途径 请慎重填写"), state: state,requestToken:requestToken,smsCodeType:smsCodeType)
        let navigationController = UINavigationController.init(rootViewController: creatNewAccoutVC)
        navigationController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func checkNetwork(){
        NetworkStatus.getNetworkStatus { (status) in
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
//        DispatchQueue.main.async {
//            self.oldWechatLogin(code: "061POMKL00dda52jb1JL01fKKL0POMKq")
//        }
       
        if (WXApi.isWXAppInstalled()) {
            let req = SendAuthReq.init()
            req.scope = "snsapi_userinfo"
            req.state = "App"
            WXApi.send(req)
        }else{
            Message.message(text: "请先安装微信")
        }
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

        }
    }
    
    func actionForWechatLoginType() {
        DispatchQueue.main.async {
            if self.stationView.origin.y != __kHeight{
                UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
                    self.stationView.origin.y = __kHeight
                }) { (completion) in
                    self.agreementButton.alpha = 1
                    self.loginButton.alpha = 1
                }
            }
            if self.commonLoginButon != nil{
                self.loginButton.removeFromSuperview()
            }
            self.commonLoginButon = self.weChatButton
            self.view.addSubview(self.commonLoginButon!)
//            self.setUpFrame()
            self.wisnucImageView.layer.borderColor = UIColor.clear.cgColor
            self.wisnucImageView.image = UIImage.init(named: "logo")
        }
        if self.cloudLoginArray != nil{
            self.cloudLoginArray?.removeAll()
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
    
    lazy var agreementButton: UIView = { [weak self] in
        let bgView = UIView.init(frame: CGRect(x: MarginsWidth, y: (self?.creatNewAccoutButton.bottom)! + 32, width: __kWidth - MarginsWidth * 2, height: 48))
        let button = UIButton.init(frame: CGRect(x: 0, y: 0, width: bgView.bounds.width, height: 13))
        
//        let str = "点击继续创建账户即表明同意闻上云盘的产品使用协议和隐私政策"
        let str = NSMutableAttributedString.init(string:"点击继续创建账户即表明同意闻上云盘的产品使用协议和隐私政策")
        str.addAttribute(NSAttributedStringKey.underlineStyle, value: NSNumber(integerLiteral: NSUnderlineStyle.styleSingle.rawValue), range: NSRange(location: 20, length: 9))
        str.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSRange(location: 0, length: str.length))
        str.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 12), range: NSRange(location: 0, length: str.length))
        button.setAttributedTitle(str, for: UIControlState.normal)
        
        button.setAttributedTitle(str, for: UIControlState.normal)
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        button.addTarget(self, action: #selector(agreementButtonClick), for: UIControlEvents.touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.titleLabel?.numberOfLines = 0
        bgView.addSubview(button)
        
//        let widthSize = labelWidthFrom(title: str, font:(button.titleLabel?.font)!)
        
//        let underline = UIView.init(frame: CGRect(origin: CGPoint(x:button.center.x - widthSize/2  , y: button.center.y + button.frame.size.height/2 + 3), size: CGSize(width: Int(widthSize), height: 1)))
//        underline.backgroundColor = UIColor.white
//
//        bgView.addSubview(underline)
        return bgView
    }()
    
    lazy var weChatButton: MDBaseButton = { [weak self] in
        let innerWechatView = MDBaseButton.init(frame: CGRect(x: MarginsWidth, y: (self?.wisnucLabel.bottom)! + 48, width: __kWidth - MarginsWidth * 2, height: ButtonHeight))
        innerWechatView.backgroundColor = .white
        innerWechatView.layer.cornerRadius = ButtonHeight/2
        innerWechatView.inkColor = COR1.withAlphaComponent(0.3)
        
        let wechatImage = UIImage.init(named: "wechat_icon_mian_color.png")
        let wechatImageView = UIImageView.init(image: wechatImage)
        innerWechatView.addSubview(wechatImageView)
        wechatImageView.snp.makeConstraints({ (make) in
            make.left.equalTo(innerWechatView.snp.left).offset(16)
            make.centerY.equalTo(innerWechatView.snp.centerY)
            make.size.equalTo((wechatImage?.size)!)
        })
        
        let label = UILabel.init();
        label.text = LocalizedString(forKey: "使用微信登录注册")
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = COR1
        label.alpha = 0.87
        label.textAlignment = .center
        
        innerWechatView.addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.centerX.equalTo(innerWechatView.snp.centerX)
            make.centerY.equalTo(innerWechatView.snp.centerY)
            make.size.equalTo(CGSize(width: labelWidthFrom(title: label.text!, font: label.font!), height: labelHeightFrom(title: label.text!, font: label.font!)))
        }
        
        innerWechatView .addTarget(self, action: #selector(weChatViewButtonClick), for: UIControlEvents.touchUpInside)
        return innerWechatView
    }()
    
    lazy var creatNewAccoutButton: MDBaseButton = { [weak self] in
        let innerView = MDBaseButton.init(frame: CGRect(x: MarginsWidth, y: (self?.weChatButton.bottom)! + 16, width: __kWidth - MarginsWidth * 2, height: ButtonHeight))
        innerView.backgroundColor = COR1
        innerView.layer.cornerRadius = ButtonHeight/2
        innerView.setBorderColor(UIColor.white, for: UIControlState.normal)
        innerView.setBorderWidth(1, for: UIControlState.normal)
        
        let label = UILabel.init()
        label.text = LocalizedString(forKey: "创建账号")
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.alpha = 0.87
        label.textAlignment = .center
        
        innerView.addSubview(label)
        
        label.snp.makeConstraints { (make) in
            make.centerX.equalTo(innerView.snp.centerX)
            make.centerY.equalTo(innerView.snp.centerY)
            make.size.equalTo(CGSize(width: labelWidthFrom(title: label.text!, font: label.font!), height: labelHeightFrom(title: label.text!, font: label.font!)))
        }
        
        innerView .addTarget(self, action: #selector(creatNewAccoutButton(_ :)), for: UIControlEvents.touchUpInside)
        return innerView
    }()
    
    lazy var loginButton: UIButton = {
        let buttonTitleString = LocalizedString(forKey: "login")
        let buttonTitleFont = MiddleTitleFont
        let width:CGFloat = labelWidthFrom(title: buttonTitleString, font: buttonTitleFont)
        let button = UIButton.init(frame: CGRect(x: __kWidth - MarginsWidth - width, y: MarginsWidth + 10, width: width, height: ButtonHeight))

        button.titleLabel?.font =  buttonTitleFont
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
        let string = LocalizedString(forKey: "欢迎使用闻上云盘")
        let font = UIFont.systemFont(ofSize: 28)
        label.font = font
        label.textColor = UIColor.white
        label.text = string
        label.textAlignment = NSTextAlignment.left
        let size = CGSize(width: Int(labelWidthFrom(title: label.text!, font: label.font!) + 20), height: Int(labelHeightFrom(title: label.text!, font: label.font!)))
        label.frame = CGRect(origin: CGPoint(x: MarginsWidth, y: MDCAppNavigationBarHeight + 118), size:size)
        return label
    }()
    
     lazy var tabbar =  UIView.init(frame: CGRect(x: 0, y: __kHeight - TabBarHeight, width: __kWidth, height: TabBarHeight))
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 }
 
 // MARK: - Delegate
 extension LoginRootViewController:StationViewDelegate{
    func stationViewSwipeAction() {
        NetEngine.sharedInstance.cancleAllRequest()
        self.logintype = .wechat
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
            if self.stationView.stationArray != nil && (self.stationView.stationArray?.count)! > 0{
                let model = self.stationView.stationArray![(sender.view?.tag)!]
                let localNetVC = LocalNetworkLoginViewController.init(model: model)
                localNetVC.delegate = self
                let navi = UINavigationController.init(rootViewController: localNetVC)
                self.present(navi, animated: true, completion: {
                    
                })
            }else{
                Message.message(text: LocalizedString(forKey: "Device is not exist"))
            }
           
        case .diskError?:
            let diskErrorVC = DiskErrorViewController.init()
            self.present(diskErrorVC, animated: true, completion: {
                
            })
        case .normal?:
            if self.cloudLoginArray != nil && (self.cloudLoginArray?.count)! > 0{
                let model = self.stationView.stationArray![(sender.view?.tag)!]
                self.normalLoginAction(model: model)
            }else{
                Message.message(text: LocalizedString(forKey: "Device is not exist"))
            }
            
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
 
 extension LoginRootViewController:AddStationDelegate{
    func addStationFinish(model: Any) {
        let transerModel = model as! CloadLoginUserRemotModel
        self.stationView.addStation(model: transerModel)
    }
    
    func addStationFinish(models: [Any]) {
        let stations = models.map{$0 as! CloadLoginUserRemotModel }
        self.stationView.addStations(models: stations)
    }
 }
 
 extension LoginRootViewController:LogOutViewControllerDelegate{
    func logOutButtonTap(sender: UIButton) {
        self.logintype = .wechat
    }
 }
 
 extension LoginRootViewController:LocalNetworkLoginViewControllerDelegate{
    struct MDCPalette {
        static let blue: UIColor = UIColor(red: 0.129, green: 0.588, blue: 0.953, alpha: 1.0)
        static let red: UIColor = UIColor(red: 0.957, green: 0.263, blue: 0.212, alpha: 1.0)
        static let green: UIColor = UIColor(red: 0.298, green: 0.686, blue: 0.314, alpha: 1.0)
        static let yellow: UIColor = UIColor(red: 1.0, green: 0.922, blue: 0.231, alpha: 1.0)
    }
    
    func dismissComplete() {
        ActivityIndicator.startActivityIndicatorAnimation()
        DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 1.5) {
            DispatchQueue.main.async {
                appDelegate.initRootVC()
            }
        }
    }
 }
 
 extension LoginRootViewController:LoginViewControllerDelegate{
    func wechatLogin() {
        self.weChatViewButtonClick()
    }
 }
 
 extension LoginRootViewController:LoginSelectionDeviceViewControllerDelegte{
    func loginFinish(userId: String, stationModel: Any) {
        ActivityIndicator.startActivityIndicatorAnimation()
        if let user = AppUserService.user(uuid: userId){
            let model = stationModel as! StationsInfoModel
            AppService.sharedInstance().loginAction(stationModel: model, orginTokenUser: user) { (error, userData) in
                if error == nil && userData != nil{
                    AppUserService.isUserLogin = true
                    AppUserService.isStationSelected = true
                    AppUserService.setCurrentUser(userData)
                    AppUserService.currentUser?.isSelectStation = NSNumber.init(value: AppUserService.isStationSelected)
                    AppUserService.synchronizedCurrentUser()
                    appDelegate.initRootVC()
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
                        AppUserService.logoutUser()
                        ActivityIndicator.stopActivityIndicatorAnimation()
                    }
                }
            }
            //
        }else{
            AppUserService.logoutUser()
            Message.message(text: ErrorLocalizedDescription.Login.NoCurrentUser, duration: 2.0)
            ActivityIndicator.stopActivityIndicatorAnimation()
        }
    }
 }
