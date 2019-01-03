//
//  LoginInputPasswordViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/12/6.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class LoginInputPasswordViewController: BaseViewController {
    let passwordLimitCount = 6
    var phone:String?
    var textFieldControllerPassword:MDCTextInputControllerUnderline?
    var alertView:TipsAlertView?
    var stationModels:[StationsInfoModel]?
    
    init(style: NavigationStyle,phone:String) {
        super.init(style: style)
        self.phone = phone
        
      
        self.prepareNotification()
        self.prepareNavigationBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = COR1
        self.view.addSubview(titleLabel)
        self.titleLabel.text = LocalizedString(forKey: "登录")
        self.setTextFieldController()

        self.view.addSubview(passwordTitleLabel)
        self.view.addSubview(passwordTextFiled)
        self.view.addSubview(nextButton)
        self.passwordTextFiled.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.stopActivityIndicator()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.alertView != nil {
            self.alertView?.dismiss()
        }
        self.view.endEditing(true)
    }
    
    func prepareNavigationBar(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: LocalizedString(forKey: "忘记密码"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(forgetPwdTap(_ :)))
    }
    
    func prepareNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(note:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //键盘即将隐藏
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden(note:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func setTextFieldController(){
        self.textFieldControllerPassword = MDCTextInputControllerUnderline.init(textInput: passwordTextFiled)
        self.textFieldControllerPassword?.isFloatingEnabled = false
        self.textFieldControllerPassword?.normalColor = UIColor.white.withAlphaComponent(0.38)
        self.textFieldControllerPassword?.activeColor = .white
    }
    
    func nextButtonDisableStyle(){
        self.nextButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        self.nextButton.isEnabled = false
    }
    
    func nextButtonEnableStyle(){
        self.nextButton.backgroundColor = UIColor.white
        self.nextButton.isEnabled = true
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
        imageView.tintColor = .white
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
    
    @objc func rightViewTap(_ gestrue:UIGestureRecognizer){
        if (gestrue.view?.isKind(of: RightImageView.self))!{
            let rightView = gestrue.view as! RightImageView
            if  rightView.type == .password{
                rightView.isSelect = !rightView.isSelect
                if rightView.isSelect{
                    rightView.image = UIImage.init(named: "eye_close.png")
                    self.passwordTextFiled.isSecureTextEntry = false
                }else{
                    rightView.image = UIImage.init(named: "eye_open.png")
                    self.passwordTextFiled.isSecureTextEntry = true
                }
            }
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
    
    @objc func forgetPwdTap(_ sender:UIBarButtonItem){
        let nextViewController = LoginNextStepViewController.init(titleString: LocalizedString(forKey: "忘记密码"), detailTitleString:LocalizedString(forKey: "如果你在“账户安全”中设置了双重身份认证，\n需要通过手机和邮箱验证"), state: .forgetPwd,smsCodeType:.password)
        nextViewController.modalTransitionStyle = .crossDissolve
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    
    @objc func nextButtontTap(_ sender:MDCFloatingButton){
        self.passwordTextFiled.resignFirstResponder()
        guard let password = self.passwordTextFiled.text else {
            return
        }
        
        if password.count == 0{
             return
        }
        
        guard  let phone = self.phone else {
            return
        }
        
        self.startActivityIndicator()
        self.nextButtonDisableStyle()
        let request = SighInTokenAPI.init(phoneNumber: phone, password: password)
        request.startRequestDataCompletionHandler{ [weak self](response) in
            ActivityIndicator.stopActivityIndicatorAnimation()
            if  response.error == nil{
                self?.stopActivityIndicator()
                do {
                    let model = try JSONDecoder().decode(SighInTokenModel.self, from: response.value!)
                    if model.code == 1 {
                        guard let header = response.response?.allHeaderFields else {
                            return
                        }
                        guard let cookie = header["Set-Cookie"] as? String else {
                            return
                        }
                        if let token = model.data?.token {
                           
                            guard (model.data?.id) != nil else{
                                return
                            }
                            self?.startActivityIndicator()
                             let user = AppUserService.synchronizedUserInLogin(model, cookie)
                            LoginCommonHelper.instance.stationAction(token: token,user:user, viewController: self!, lastDeviceClosure:{ [weak self](user,stationModel,models)  in
                                self?.stopActivityIndicator()
                                self?.stationModels = models
                                self?.loginFinish(user: user, stationModel: stationModel, stationModels:models)
                            })
                        }
                    }else{
                        if let errorString = ErrorTools.responseErrorData(response.data){
                            Message.message(text: errorString)
                        }
                        self?.nextButtonEnableStyle()
                        print(response.error as Any)
                    }

                } catch {
                    // 异常处理
                     self?.nextButtonEnableStyle()
                    Message.message(text: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail)
                }
            }else{
                // error
                self?.stopActivityIndicator()
                self?.nextButtonDisableStyle()
                if response.data != nil {
                    let errorDict =  dataToNSDictionary(data: response.data!)
                    if errorDict != nil{
                        Message.message(text: errorDict!["message"] != nil ? errorDict!["message"] as! String :  (response.error?.localizedDescription)!)
                    }else{
                        let backToString = String(data: response.data!, encoding: String.Encoding.utf8) as String?
                        Message.message(text: backToString ?? "error")
                    }
                }else{
                    Message.message(text: "\(String(describing: response.error?.localizedDescription ?? "未知错误"))")
                }
                self?.nextButtonEnableStyle()
            }
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: MarginsWidth, y: MDCAppNavigationBarHeight + 25, width: __kWidth - MarginsWidth*2 , height: 28))
        label.font = UIFont.systemFont(ofSize: 28)
        label.textColor = .white
        return label
    }()
    
    lazy var passwordTitleLabel: UILabel = {  [weak self] in
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: (self?.titleLabel.bottom)! + 46, width: __kWidth - MarginsWidth*2, height: 12))
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.text = LocalizedString(forKey: "密码")
        
        return label
        }()
    
    lazy var passwordTextFiled: MDCTextField = { [weak self] in
        let textInput = MDCTextField.init(frame: CGRect(x: MarginsWidth, y: (self?.passwordTitleLabel.bottom)! + MarginsWidth, width: __kWidth - MarginsWidth*2, height: 80))
        textInput.leftViewMode = .always
        textInput.textColor = .white
        textInput.font = UIFont.systemFont(ofSize: 18)
        textInput.isSecureTextEntry = true
        textInput.leftView = self?.leftView(image: UIImage.init(named: "lock.png"))
        
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
        button.setImage(UIImage.init(named: "next_button_arrow"), for: UIControlState.normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        button.isEnabled = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = width/2
        button.addTarget(self, action: #selector(nextButtontTap(_:)), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    
}

extension LoginInputPasswordViewController:TipsAlertViewDelegate{
    func alertDismiss(animateDuration: TimeInterval) {
        UIView.animate(withDuration: animateDuration) {
            self.nextButton.center = CGPoint(x: self.nextButton.center.x, y: __kHeight - MarginsWidth - self.nextButton.height/2)
        }
    }
}

extension LoginInputPasswordViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let rawText = textField.text else {
            return true
        }
    
        let fullString = NSString(string: rawText).replacingCharacters(in: range, with: string)

        if fullString.count >= passwordLimitCount {
            self.nextButtonEnableStyle()
        }else{
            self.nextButtonDisableStyle()
        }
        
        if textField.isSecureTextEntry == true {
            textField.text = fullString
            return false
        }
        return true
    }
}

extension LoginInputPasswordViewController:LoginSelectionDeviceViewControllerDelegte{
    func loginFinish(user: User, stationModel: Any, stationModels: [Any]?) {
//        guard let deviceModels = stationModels as? [StationsInfoModel] else{
//            return
//        }
//        if !deviceModels.contains(where: {$0.sn == user.stationId}){
//            Message.message(text: LocalizedString(forKey: "您不拥有该设备，请重新登录"))
//            AppUserService.logoutUser()
//            return
//        }
        let model = stationModel as! StationsInfoModel
        self.startActivityIndicator()
        AppService.sharedInstance().loginAction(stationModel: model, orginTokenUser: user) { (error, userData) in
             self.nextButton.isEnabled = true
            if error == nil && userData != nil{
                AppUserService.isUserLogin = true
                AppUserService.isStationSelected = true
                userData?.isSelectStation = NSNumber.init(value: true)
                AppUserService.setCurrentUser(userData)
                AppUserService.synchronizedCurrentUser()
                self.stopActivityIndicator()
                appDelegate.initRootVC()
            }else{
                if error != nil{
                    self.stopActivityIndicator()
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
                self.nextButtonEnableStyle()
            }
        }
    }
}
