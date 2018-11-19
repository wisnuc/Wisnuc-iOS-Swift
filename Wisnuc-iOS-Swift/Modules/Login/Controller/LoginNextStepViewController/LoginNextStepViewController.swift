//
//  LoginNextStepViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/8/28.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

enum LoginNextStepViewControllerState{
    case forgetPwd
    case verifyCode
    case resetPwd
    case bindPhoneNumber
    case bindPhoneWechat
    case creatPwd
    case bindPhoneWechatCreatPwd
    case signUpVerifyCode
    case wechatSignUpVerifyCode
    case wechatLoginVerifyCode
    case creatAccountFinish
}

enum RightViewType{
    case password
    case right
}

class LoginNextStepViewController: BaseViewController {
    private var phoneNumber:String?
    private var password:String?
    private var verifyCode:String?
    private var requestToken:String?
    private var userExist:Bool?
    private var smsCodeType:SmsCodeType?
    let phoneNumberLimitCount = 11
    let verifyCodeLimitCount = 4
    let passwordLimitCount = 8
    var alertView:TipsAlertView?
    var textFieldController:MDCTextInputControllerUnderline?
    var state:LoginNextStepViewControllerState?{
        didSet{
            switch self.state {
            case .forgetPwd?:
                phoneNumberStyle()
            case .verifyCode?,.signUpVerifyCode?,.wechatSignUpVerifyCode?,.wechatLoginVerifyCode?:
                verifyCodeStyle()
            case .resetPwd?,.creatPwd?,.bindPhoneWechatCreatPwd?:
                resetPwdStyle()
            case .bindPhoneNumber?,.bindPhoneWechat?:
                bindPhoneNumberStyle()
            case .creatAccountFinish?:
                creatAccountFinishStyle()
            default:
                break
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
  
    init(titleString:String,detailTitleString:String?,state:LoginNextStepViewControllerState,phoneNumber:String? = nil,password:String? = nil,verifyCode:String? = nil,requestToken:String? = nil,userExist:Bool? = nil,smsCodeType:SmsCodeType? = nil) {
        super.init()
        titleLabel.text = titleString
        detailTitleLabel.text = detailTitleString
        setState(state:state)
        self.phoneNumber = phoneNumber
        self.password = password
        self.verifyCode = verifyCode
        self.requestToken = requestToken
        self.userExist = userExist
        self.smsCodeType = smsCodeType
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.frame = CGRect(x: 0, y: 0, width: __kWidth, height: __kHeight)
        self.navigationController?.delegate = self
        if self.state != .creatAccountFinish{
            self.inputTextField.becomeFirstResponder()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.alertView != nil {
            self.alertView?.dismiss()
        }
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareNotification()
        self.view.backgroundColor = COR1
        view.addSubview(titleLabel)
        view.addSubview(detailTitleLabel)
        detailTitleLabel.sizeToFit()
        view.addSubview(textFiledTitleLabel)
        view.addSubview(inputTextField)
        self.preparerTextFieldController()

        view.addSubview(nextButton)
        self.nextButton.addTarget(self, action: #selector(nextButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        setRightView()
        // Do any additional setup after loading the view.
    }
    
    func prepareNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(note:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //键盘即将隐藏
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden(note:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setState(state:LoginNextStepViewControllerState){
        self.state = state
    }
    
    func phoneNumberStyle(){
        self.textFiledTitleLabel.text = LocalizedString(forKey: "手机号")
    }
    
    func verifyCodeStyle(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: LocalizedString(forKey: "帮助"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(helpTap(_ :)))
        self.textFiledTitleLabel.text = LocalizedString(forKey: "验证码")
        self.inputTextField.leftView = nil
        
    }
    
    func  resetPwdStyle(){
        self.textFiledTitleLabel.text = LocalizedString(forKey: "密码")
        self.inputTextField.isSecureTextEntry = true
        self.inputTextField.leftView = self.leftView(image: UIImage.init(named: "lock.png"))
        self.inputTextField.keyboardType = .default
    }
    
    func bindPhoneNumberStyle(){
        phoneNumberStyle()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: MDCIcons.imageFor_ic_arrow_back()?.byTintColor(UIColor.white), style: UIBarButtonItemStyle.plain, target: self, action: #selector(backTap(_ :)))
    }
    
    func creatAccountFinishStyle(){
        self.textFiledTitleLabel.isHidden = true
        self.inputTextField.isHidden = true
        let rectWidth:CGFloat = 48
        self.successImageView.frame = CGRect(x: __kWidth/2 - rectWidth/2, y: self.detailTitleLabel.bottom + 44 , width: rectWidth, height: rectWidth)
        self.view.addSubview(self.successImageView)
        nextButtonEnableStyle()
        appBar.headerViewController.navigationItem.backBarButtonItem = nil
        appBar.navigationBar.backItem = nil
    }
    
    func preparerTextFieldController() {
        self.textFieldController = MDCTextInputControllerUnderline.init(textInput: inputTextField)
        self.textFieldController?.isFloatingEnabled = false
        self.textFieldController?.normalColor = UIColor.white.withAlphaComponent(0.38)
        self.textFieldController?.activeColor = .white
//        self.textFieldController?.tr
//        self.textFieldController?.textInsets(UIEdgeInsets.init(top: 100, left: -100, bottom: 100, right: 100))
//        self.textFieldController?.textInputDidUpdateConstraints()
    }
    
    func nextButtonDisableStyle(){
        self.nextButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        self.nextButton.isEnabled = false
    }
    
    func nextButtonEnableStyle(){
        self.nextButton.backgroundColor = UIColor.white
        self.nextButton.isEnabled = true
    }
    
    func setRightView(){
        if state == .resetPwd ||  state == .creatPwd || state == .bindPhoneWechatCreatPwd{
          self.inputTextField.rightView = self.rightView(type: RightViewType.password)
        }
    }
    
    func leftView(image:UIImage?) -> UIView{
        let leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: 36 + 12, height: 24))
        let imageView = UIImageView.init(image:image)
        leftView.layer.cornerRadius = 2
        imageView.frame = CGRect(x: 0, y: 0, width: 36, height: 24)
        leftView.addSubview(imageView)
        leftView.backgroundColor = .clear
        return leftView
    }
    
    func rightView(type:RightViewType) -> UIImageView{
        var image:UIImage?
        switch type {
        case .right:
            image = UIImage.init(named: "text_right")
        case .password:
            image = UIImage.init(named: "eye_open")
        default:
            image = UIImage.init(named: "text_right")
        }
        
        let imageView = RightImageView.init(image:image)
        imageView.type = type
        imageView.frame = CGRect(x: 0, y: 0, width: (image?.width)!, height: (image?.height)!)
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(rightViewTap(_ :)))
        imageView.addGestureRecognizer(tap)
        return imageView
    }
    
    func alertError(errorText:String){
        for view in (kWindow?.subviews)!{
            if view.isKind(of: TipsAlertView.self){
                let alert = view as! TipsAlertView
                alert.dismiss()
            }
        }
        let alertView = TipsAlertView.init(errorMessage: LocalizedString(forKey: errorText))
        alertView.alert()
        alertView.delegate = self
        self.alertView = alertView
        UIView.animate(withDuration: alertView.alertDuration()) {
            self.nextButton.center = CGPoint(x: self.nextButton.center.x, y:self.nextButton.center.y - alertView.height)
        }
    }
    
    //键盘弹出监听
    @objc func keyboardShow(note: Notification)  {
        if self.alertView != nil {
            self.alertView?.dismiss()
        }
        guard let userInfo = note.userInfo else {return}
        guard let keyboardRect = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else{return}
        //获取键盘弹起的高度
        let keyboardTopYPosition =  keyboardRect.origin.y
        let duration = note.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        UIView.animate(withDuration: duration) {
            self.nextButton.center = CGPoint(x: self.nextButton.center.x, y: keyboardTopYPosition - 36)
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
            self.nextButton.center = CGPoint(x: self.nextButton.center.x, y:keyboardTopYPosition - MarginsWidth - self.nextButton.height/2 )
        }
    }
    
    @objc func nextButtonTap(_ sender:MDCFloatingButton){
        self.inputTextField.resignFirstResponder()
        switch self.state {
        case .forgetPwd?:
            verifyCodePush()
        case .verifyCode?,.signUpVerifyCode?,.wechatSignUpVerifyCode?:
            resetOrCreatPwdPush()
        case .wechatLoginVerifyCode?:
            smsCodeLogin()
        case .resetPwd?:
            resetPwdFinish()
        case .bindPhoneNumber?,.bindPhoneWechat?:
            verifyCodePush()
        case .creatPwd?,.bindPhoneWechatCreatPwd?:
            creatAccountFinish()
        case .creatAccountFinish?:
            firstConfigAction()
//        defaultNotificationCenter().post(name: NSNotification.Name.Login.CreatAccountFinishDismissKey, object: nil)
        default:
            break
        }
    }
    
    @objc func helpTap(_ sender:UIBarButtonItem){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cancelAction = UIAlertAction (title: LocalizedString(forKey: "取消"), style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(cancelAction)
        let changePhoneNumberAction = UIAlertAction (title: LocalizedString(forKey: "更改我的手机号"), style: UIAlertActionStyle.default, handler: { (alertAction) in
            self.navigationController?.popViewController(animated: true)
        })
        
        alertController.addAction(changePhoneNumberAction)
        let verifyCodeAction = UIAlertAction (title: LocalizedString(forKey: "再次发送验证码"), style: UIAlertActionStyle.default, handler: { (alertAction) in
            guard let smsCodeType = self.smsCodeType else{
                Message.message(text: "无法发送验证码")
                return
            }
            self.sendCodeAction(type:smsCodeType) { (userExist) in
                Message.message(text: "验证码已重新发送，请注意查收")
            }
        })
        alertController.addAction(verifyCodeAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func backTap(_ sender:UIBarButtonItem){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func rightViewTap(_ gestrue:UIGestureRecognizer){
        if self.alertView != nil {
            self.alertView?.dismiss()
        }
        if (gestrue.view?.isKind(of: RightImageView.self))!{
            let rightView = gestrue.view as! RightImageView
            if  rightView.type == .password{
                rightView.isSelect = !rightView.isSelect
                if rightView.isSelect{
                    rightView.image = UIImage.init(named: "eye_close.png")
                    self.inputTextField.isSecureTextEntry = false
                }else{
                    rightView.image = UIImage.init(named: "eye_open.png")
                    self.inputTextField.isSecureTextEntry = true
                }
            }
        }
    }
    
    func verifyCodePush(){
        if isNilString(self.inputTextField.text)  {
            self.alertError(errorText: LocalizedString(forKey: "手机号不能为空"))
            return
        }else if !checkIsPhoneNumber(number: self.inputTextField.text!){
            self.alertError(errorText: LocalizedString(forKey:"请输入正确的手机号"))
            return
        }
        
        guard let smsCodeType = self.smsCodeType else{
            Message.message(text: "无法发送验证码")
            return
        }
       
        self.sendCodeAction(type: smsCodeType) { [weak self] (userExist) in
            var state = LoginNextStepViewControllerState.verifyCode
            switch self?.state {
            case .bindPhoneNumber?:
               state = LoginNextStepViewControllerState.signUpVerifyCode
            case .bindPhoneWechat?:
               state = LoginNextStepViewControllerState.wechatSignUpVerifyCode
            default:
                break
            }
        
            let nextViewController = LoginNextStepViewController.init(titleString: LocalizedString(forKey: "请输入验证码"), detailTitleString: LocalizedString(forKey: "我们向 \(String(describing: self?.inputTextField.text ?? "手机号")) 发送了一个验证码 请在下面输入"), state: state,phoneNumber:(self?.inputTextField.text)!,requestToken:self?.requestToken,userExist:userExist,smsCodeType:self?.smsCodeType)
            nextViewController.modalTransitionStyle = .crossDissolve
            self?.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    func sendCodeAction(type:SmsCodeType,callback:@escaping ((_ userExist:Bool?)->())){
        ActivityIndicator.startActivityIndicatorAnimation()
        var phone = self.inputTextField.text
        if !checkIsPhoneNumber(number: self.inputTextField.text){
            if let phoneNumer = self.phoneNumber{
                phone = phoneNumer
            }
        }
        guard let phoneNumer = phone else {
            Message.message(text: "手机号不正确")
            return
        }
        GetSmsCodeAPI.init(phoneNumber: phoneNumer,type:type,wechatToken:self.requestToken).startRequestJSONCompletionHandler { [weak self] (response) in
//            print(String(data: response.data!, encoding: String.Encoding.utf8) as String? ?? "2222")
            if  response.error == nil{
                let responseDic = response.value as! NSDictionary
                let code = responseDic["code"] as? Int
                if code == 1 {
                    var userExist:Bool?
                    if responseDic["data"] != nil{
                        let dataDic = responseDic["data"] as! NSDictionary
                        userExist = dataDic["userExist"] as? Bool
                    }
                    ActivityIndicator.stopActivityIndicatorAnimation()
                    callback(userExist)
                }else{
                    
                    if let message = ErrorTools.responseErrorData(response.data){
                        Message.message(text:"error: code:\(code!) message:\(message)")
                    }
                    ActivityIndicator.stopActivityIndicatorAnimation()
                }
            }else{
                // error
                ActivityIndicator.stopActivityIndicatorAnimation()
                guard let responseDic =  dataToNSDictionary(data: response.data) else{
                    if response.error is BaseError{
                        let baseError = response.error as! BaseError
                        Message.message(text:"请求错误：\(String(describing: baseError.localizedDescription))")
                    }else{
                        let message = response.error?.localizedDescription ?? "未知原因"
                        Message.message(text:"请求错误：\(message)")
                    }
                    return
                }
                 if let code = responseDic["code"] as? Int{
                   
                    switch code {
                    case ErrorCode.Request.UserAlreadyExist:
                        if self?.state == .bindPhoneWechat{
                            self?.sendLoginSmsCode()
                        }else{
                            Message.message(text: LocalizedString(forKey: "该账号已注册"))
                        }
                    case ErrorCode.Request.MobileError:
                        Message.message(text: LocalizedString(forKey: "手机号错误"))
                    case ErrorCode.Request.CodeLimitOut:
                        Message.message(text: LocalizedString(forKey: "验证码发送超过限制，请稍候重试"))
                    default:
                        if let message = responseDic["message"] as? String{
                            Message.message(text:"\(message)")
                        }
                    }
                 }else{
                     Message.message(text: "error code :\(String(describing: response.response?.statusCode ?? -0)) error:\(String(describing: response.error?.localizedDescription ?? "未知错误"))")
                 }
            }
        }
    }
    
    func sendLoginSmsCode(){
        let sendType:SmsCodeType = .login
        self.sendCodeAction(type: sendType) { [weak self](userExist) in
            let state = LoginNextStepViewControllerState.wechatLoginVerifyCode
            let nextViewController = LoginNextStepViewController.init(titleString: LocalizedString(forKey: "请输入验证码"), detailTitleString: LocalizedString(forKey: "我们向 \(String(describing: self?.inputTextField.text ?? "手机号")) 发送了一个验证码 请在下面输入"), state: state,phoneNumber:(self?.inputTextField.text)!,requestToken:self?.requestToken,smsCodeType:sendType)
            nextViewController.modalTransitionStyle = .crossDissolve
            self?.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    func resetOrCreatPwdPush(){
        var state = LoginNextStepViewControllerState.resetPwd
        var titleString = LocalizedString(forKey: "重置密码")
        switch self.state {
        case .signUpVerifyCode?:
            state = LoginNextStepViewControllerState.creatPwd
            titleString = LocalizedString(forKey: "创建密码")
        case .wechatSignUpVerifyCode?:
            state = LoginNextStepViewControllerState.bindPhoneWechatCreatPwd
            titleString = LocalizedString(forKey: "创建密码")
        default:
            break
        }
        
        if state == LoginNextStepViewControllerState.resetPwd{
            self.getTicket { [weak self](ticket) in
                if let ticket = ticket{
                   self?.nextViewControllerForPassword(titleString: titleString, state: state, requestToken: ticket)
                }
            }
        }else{
            self.nextViewControllerForPassword(titleString: titleString, state: state, requestToken: self.requestToken)
        }
    }
    
    func nextViewControllerForPassword(titleString:String,state:LoginNextStepViewControllerState,requestToken:String?){
        let nextViewController = LoginNextStepViewController.init(titleString:titleString , detailTitleString: LocalizedString(forKey: "您的密码必须包含至少1个符号，长度至少为8个字符"), state: state,phoneNumber:self.phoneNumber!,verifyCode:self.inputTextField.text!,requestToken:requestToken,userExist:self.userExist)
        nextViewController.modalTransitionStyle = .crossDissolve
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func getTicket(closure:@escaping (_ ticket:String?)->()) {
        guard let phone = self.phoneNumber else {
            return
        }
        guard let code = self.inputTextField.text else {
            return
        }
        
        ActivityIndicator.startActivityIndicatorAnimation()
        let request = SmsCodeTicket.init(phone:phone, code: code,type:.password)
        request.startRequestJSONCompletionHandler { (response) in
            ActivityIndicator.stopActivityIndicatorAnimation()
            if let error = response.error{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                }else{
                    Message.message(text:error.localizedDescription)
                }
            }else{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                    return
                }
                guard let rootDic = response.value as? NSDictionary else{
                    return
                }
                guard let smsCodeTicket = rootDic["data"] as? String else{
                    return
                }
                
                return closure(smsCodeTicket)
            }
        }
    }
    
    func resetPwdFinish(){
       
        guard let token = self.requestToken else {
            return
        }
        
        guard let phone = self.phoneNumber else {
            return
        }
        
        guard let password = self.inputTextField.text else {
            return
        }
        
        ActivityIndicator.startActivityIndicatorAnimation()
        let request = ResetPasswordAPI.init(token: token, phone: phone, password: password)
        request.startRequestJSONCompletionHandler { [weak self](response) in
             ActivityIndicator.stopActivityIndicatorAnimation()
            if let error = response.error{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                }else{
                    Message.message(text:error.localizedDescription)
                }
            }else{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                    return
                }
                 Message.message(text:"重置密码成功")
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    func creatAccountFinish(){
        ActivityIndicator.startActivityIndicatorAnimation()
        let request = SighUpAPI.init(phoneNumber: self.phoneNumber! , code:self.verifyCode!, password:self.inputTextField.text!)
        request.startRequestDataCompletionHandler { [weak self](response) in
            if  response.error == nil{
                    do {
                        let model = try JSONDecoder().decode(SighInTokenModel.self, from: response.value!)
                        if model.code == 1 {
                            if let token = model.data?.token {
                                if  self?.state == .bindPhoneWechatCreatPwd{
                                    guard let wechatToken = self?.requestToken else{
                                        Message.message(text:LocalizedString(forKey: "发生错误"))
                                        return
                                    }
                                    self?.wechatBindUserAction(wechatToken: wechatToken, loginToken: token, closure: { [weak self] in
                                        self?.pushToFinishView()
                                    })
                                }else{
                                    self?.pushToFinishView()
                                }
                                guard (model.data?.id) != nil else{
                                    return
                                }
                                self?.synchronizedUser(model)
                            }
                        }else{
                            if let errorMessage = ErrorTools.responseErrorData(response.data){
                                Message.message(text:errorMessage)
                            }
                        }
                    } catch {
                        // 异常处理
                        Message.message(text: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail)
                    }
                    ActivityIndicator.stopActivityIndicatorAnimation()
            }else{
                // error
                Message.message(text: "error code :\(String(describing: response.response?.statusCode ?? -0)) error:\(String(describing: response.error?.localizedDescription ?? "未知错误"))")
                print(String(data: response.data!, encoding: String.Encoding.utf8) as String? ?? "2222")
            }
            ActivityIndicator.stopActivityIndicatorAnimation()
        }
    }
    
    func synchronizedUser( _ model:SighInTokenModel){
        let user = AppUserService.createUser(uuid: (model.data?.id)!)
        user.cloudToken = model.data?.token!
        if let avatarUrl = model.data?.avatarUrl{
            user.avaterURL = avatarUrl
        }
        
        if let nickName = model.data?.nickName{
            user.nickName = nickName
        }
        
        if let username = model.data?.username{
            user.userName = username
        }
        
        AppUserService.setCurrentUser(user)
        AppUserService.synchronizedCurrentUser()
    }
    
    func firstConfigAction() {
         self.navigationController?.delegate = nil
        let cofigVC = FirstConfigViewController.init(style: NavigationStyle.whiteWithoutShadow)
         cofigVC.modalTransitionStyle = .coverVertical
        self.navigationController?.pushViewController(cofigVC, animated: true)
    }
    
    func pushToFinishView(){
        let nextViewController = LoginNextStepViewController.init(titleString: LocalizedString(forKey: "账号创建成功"), detailTitleString: LocalizedString(forKey: "欢迎使用闻上云盘"), state: .creatAccountFinish)
        nextViewController.modalTransitionStyle = .crossDissolve
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func smsCodeLogin(){
        guard let phoneNumber = self.phoneNumber else {
            Message.message(text: "错误，原因：没有手机号")
            return
        }
        guard let code = self.inputTextField.text else {
            Message.message(text: "错误，原因：没有验证码")
            return
        }
        ActivityIndicator.startActivityIndicatorAnimation()
        let request = SighInTokenAPI.init(phoneNumber: phoneNumber, code: code)
        request.startRequestDataCompletionHandler{ [weak self](response) in
            ActivityIndicator.stopActivityIndicatorAnimation()
            if  response.error == nil{
                do {
                    let model = try JSONDecoder().decode(SighInTokenModel.self, from: response.value!)
                    if model.code == 1 {
                        if let token = model.data?.token {
                            guard let userId = model.data?.id else{
                                return
                            }
                            self?.synchronizedUser(model)
                            guard let wechatToken = self?.requestToken else{
                                Message.message(text:LocalizedString(forKey: "发生错误"))
                                return
                            }
                            self?.wechatBindUserAction(wechatToken: wechatToken, loginToken: token, closure: {
                                LoginCommonHelper.instance.stationAction(token: token,userId:userId, viewController: self!)
                            })
                        }
                    }else{
                        if let errorString = ErrorTools.responseErrorData(response.data){
                            Message.message(text: errorString)
                        }
                    }

                } catch {
                    // 异常处理
                    Message.message(text: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail)
                }
                ActivityIndicator.stopActivityIndicatorAnimation()
            }else{
                // error
                if response.data != nil {
                    let errorDict =  dataToNSDictionary(data: response.data!)
                    if errorDict != nil{
                        Message.message(text: errorDict!["message"] != nil ? errorDict!["message"] as! String :  (response.error?.localizedDescription)!)
                    }else{
                        let backToString = String(data: response.data!, encoding: String.Encoding.utf8) as String?
                        Message.message(text: backToString ?? "error")
                    }
                }else{
                    Message.message(text: "error code :\(String(describing: response.response?.statusCode ?? -0)) error:\(String(describing: response.error?.localizedDescription ?? "未知错误"))")
                }
                ActivityIndicator.stopActivityIndicatorAnimation()
            }
        }
    }
    
    func wechatBindUserAction(wechatToken:String,loginToken:String,closure:@escaping ()->()){
        ActivityIndicator.stopActivityIndicatorAnimation()
        let request = SighInWechatUser.init(wechatToken: wechatToken, loginToken: loginToken)
        request.startRequestJSONCompletionHandler {(response) in
            if  response.error == nil{
                let responseDic = response.value as! NSDictionary
                let code = responseDic["code"] as? Int
                if code == 1 {
                  return closure()
                }else{
                    if let errorMessage = ErrorTools.responseErrorData(response.data){
                        Message.message(text:errorMessage)
                    }
                }
            }else{
                Message.message(text:(response.error?.localizedDescription)!)
            }
            
            ActivityIndicator.stopActivityIndicatorAnimation()
        }
    }
    
    
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: MarginsWidth, y: MDCAppNavigationBarHeight + 25, width: __kWidth - MarginsWidth*2 , height: 28))
        label.font = UIFont.systemFont(ofSize: 28)
        label.textColor = .white
        return label
    }()
    
    lazy var detailTitleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: MarginsWidth, y: titleLabel.bottom + MarginsWidth, width: __kWidth - MarginsWidth*2 , height: 28))
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    lazy var textFiledTitleLabel: UILabel = {  [weak self] in
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: (self?.detailTitleLabel.bottom)! + 46, width: __kWidth - MarginsWidth*2, height: 12))
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        return label
    }()
    
    lazy var inputTextField: MDCTextField = { [weak self] in
        let textInput = MDCTextField.init(frame: CGRect(x: MarginsWidth, y: (self?.textFiledTitleLabel.bottom)! + 16, width: __kWidth - MarginsWidth*2, height: 120))
        textInput.keyboardType = .phonePad
        textInput.textColor = .white
        textInput.font = UIFont.systemFont(ofSize: 16)
        textInput.leftView = self?.leftView(image: UIImage.init(named: "86.png"))
        textInput.leftViewMode = .always
        textInput.clearButtonMode = .never
        if #available(iOS 10.0, *) {
            textInput.adjustsFontForContentSizeCategory = true
        } else {
            textInput.mdc_adjustsFontForContentSizeCategory = true
        }
        textInput.delegate = self
        textInput.rightViewMode = .always
        return textInput
    }()

    lazy var nextButton: UIButton = {
        let button = UIButton.init(type: .custom)
        let width:CGFloat = 40
        button.frame = CGRect(x: __kWidth - MarginsWidth - width , y: __kHeight - MarginsWidth - width, width: width, height: width)
        button.setImage(UIImage.init(named: "next_button_arrow"), for: UIControlState.normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        button.isEnabled = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = width/2
        return button
    }()
    
    lazy var successImageView: UIImageView = UIImageView.init(image: UIImage.init(named: "success_white.png"))
}

extension LoginNextStepViewController:TipsAlertViewDelegate{
    func alertDismiss(animateDuration: TimeInterval) {
        UIView.animate(withDuration: animateDuration) {
            self.nextButton.center = CGPoint(x: self.nextButton.center.x, y: __kHeight - MarginsWidth - self.nextButton.height/2)
        }
    }
}

extension LoginNextStepViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let rawText = textField.text else {
            return true
        }
        
        let fullString = NSString(string: rawText).replacingCharacters(in: range, with: string)
        print(fullString)
        switch state {
        case .bindPhoneNumber?,.bindPhoneWechat?,.forgetPwd?:
            if  fullString.count > phoneNumberLimitCount {
                self.inputTextField.text = textField.text?.subString(to: phoneNumberLimitCount)
                return false
            }
            if checkIsPhoneNumber(number: fullString) {
                self.nextButtonEnableStyle()
                textField.rightView = self.rightView(type: RightViewType.right)
            }else{
                self.nextButtonDisableStyle()
                textField.rightView = nil
            }
            
        case .verifyCode?, .signUpVerifyCode?,.wechatSignUpVerifyCode?,.wechatLoginVerifyCode?:
            if  fullString.count > verifyCodeLimitCount {
                self.inputTextField.text = textField.text?.subString(to: verifyCodeLimitCount)
                return false
            }
            if fullString.count == verifyCodeLimitCount {
                self.nextButtonEnableStyle()
                textField.rightView = self.rightView(type: RightViewType.right)
            }else{
                self.nextButtonDisableStyle()
                textField.rightView = nil
            }
            
        case .resetPwd?,.creatPwd?,.bindPhoneWechatCreatPwd?:
            if fullString.count >= passwordLimitCount {
                self.nextButtonEnableStyle()
            }else{
                self.nextButtonDisableStyle()
            }
        default:
            break
        }
        return true
    }
}

extension LoginNextStepViewController:UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = LoginTransition()
        return transition
    }
}

class RightImageView: UIImageView {
    var type:RightViewType?
    var isSelect:Bool = false
    override init(image: UIImage?) {
        super.init(image: image)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
