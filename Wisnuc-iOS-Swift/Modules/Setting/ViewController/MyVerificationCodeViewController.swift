//
//  MyVerificationCodeViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/12.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import Material

enum MyVerificationCodeViewControllerState {
    case email
    case phone
}

enum MyVerificationCodeViewControllerNextState {
    case bindEmail
    case exchangeEmail
    case emailCodeVerification
    case passwordEmailCodeVerification
    case bindEmailComplete
    case bindPhone
    case changePassword
    case resetPassword
    case setSamba
}

class MyVerificationCodeViewController: BaseViewController {
    var phoneNumber:String?
    var mail:String?
    let textFieldHeight:CGFloat = 64
    var countdownTimer: Timer?
    var extrakeyButton:UIButton?
    var codeLimit:Int = 4
    var phoneTicket:String?
    var sendCodeType:SendCodeType?
    var remainingSeconds: Int = 0 {
        willSet {
            let text = LocalizedString(forKey: "\(newValue)秒后重新获取")
            sendButton.setTitle(text, for: .normal)
            let font = UIFont.systemFont(ofSize: 14)
            let width:CGFloat = labelWidthFrom(title: text, font: font) + 3
            sendButton.frame = CGRect(x: __kWidth - MarginsWidth - width , y: self.inputTextField.top, width:  width, height: textFieldHeight)
            if newValue <= 0 {
                let text = LocalizedString(forKey: "重新获取验证码")
                sendButton.setTitle(text, for: .normal)
                let font = UIFont.systemFont(ofSize: 14)
                let width:CGFloat = labelWidthFrom(title: text, font: font) + 3
                sendButton.frame = CGRect(x: __kWidth - MarginsWidth - width , y: self.inputTextField.top, width:  width, height: textFieldHeight)
                isCounting = false
            }
        }
    }
    
    var isCounting = false {
        willSet {
            if newValue {
                countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime(_:)), userInfo: nil, repeats: true)
                
                remainingSeconds = 60
    
            } else {
                countdownTimer?.invalidate()
                countdownTimer = nil
            }
            
            sendButton.isEnabled = !newValue
        }
    }

    var state:MyVerificationCodeViewControllerState?{
        didSet{
            switch state {
            case .email?:
                emailStateAction()
            case .phone?:
                phoneStateAction()
            default:
                break
            }
        }
    }
    
    var nextState:MyVerificationCodeViewControllerNextState?
    
    init(style: NavigationStyle,state:MyVerificationCodeViewControllerState,nextState:MyVerificationCodeViewControllerNextState,codeType:SendCodeType? = nil,phone:String? = nil,mail:String? = nil,phoneTicket:String? = nil) {
        super.init(style: style)
        self.phoneNumber = phone
        self.mail = mail
        self.sendCodeType = codeType
        self.phoneTicket = phoneTicket
        self.setState(state)
        self.nextState = nextState
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContentFrame()
        prepareNotification()
        self.view.addSubview(titleLabel)
        self.view.addSubview(detailLabel)
        self.view.addSubview(inputTextField)
        self.view.addSubview(sendButton)
        self.view.addSubview(nextButton)
        inputTextField.becomeFirstResponder()
        isCounting = true
        // Do any additional setup after loading the view.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
    
    func prepareNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(noti:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //键盘即将隐藏
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden(note:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func setState(_ state:MyVerificationCodeViewControllerState){
        self.state = state
    }
    
    func setContentFrame(){
       

    }
    
    func nextButtonDisableStyle(){
        self.nextButton.backgroundColor = COR1.withAlphaComponent(0.26)
        self.nextButton.isEnabled = false
    }
    
    func nextButtonEnableStyle(){
        self.nextButton.backgroundColor = COR1
        self.nextButton.isEnabled = true
    }
    
    func emailStateAction(){
        var mail = ""
        if let mailAdress = self.mail{
            mail = mailAdress
        }
        detailLabel.text = "4位验证码已发送至：\n\(mail)(绑定邮箱)"
        detailLabel.frame = CGRect(x: MarginsWidth, y: titleLabel.bottom + MarginsWidth, width: __kWidth - MarginsWidth*2, height: 14*3)
        inputTextField.keyboardType = .numberPad
//        let keyboard = KeyBoardView.init()
//        keyboard.delegate = self
//        inputTextField.inputView = keyboard
    }
    
    func phoneStateAction(){
        var phone = ""
        if let phoneNumber = self.phoneNumber{
            if  let replacePhone = phoneNumber.replacePhone(){
                phone = replacePhone
            }
        }
        detailLabel.text = "验证码已发送至您的手机号：\(phone)"
        detailLabel.frame = CGRect(x: MarginsWidth, y: titleLabel.bottom + MarginsWidth, width: __kWidth - MarginsWidth*2, height: 14)
        inputTextField.inputView = nil
        inputTextField.keyboardType = .numberPad
    }
    
    func getSmsCodeTicket(closure:@escaping (_ ticket:String?)->()){
        guard let phone = self.phoneNumber else {
            return
        }
        guard let code = self.inputTextField.text else {
            return
        }
        
        guard let codeType = self.sendCodeType else {
            return
        }
        
        ActivityIndicator.startActivityIndicatorAnimation()
        let request = SmsCodeTicket.init(phone:phone, code: code,type:codeType)
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
    
    func mailAction(method:RequestHTTPMethod,callback:@escaping ()->()){
        guard let mail = self.mail, let code = self.inputTextField.text else {
            return
        }
        let requset = UserMailAPI.init(method,mail:mail,code:code)
        requset.startRequestJSONCompletionHandler { (response) in
            if let error = response.error {
                Message.message(text: error.localizedDescription)
            }else{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                    return
                }
               return callback()
            }
        }
    }
    
    func sendCodeAction(type:SendCodeType,callback:@escaping (()->())){
        guard let phone = self.phoneNumber else {
            Message.message(text: "没有绑定手机号")
            return
        }
        
        if !Validate.phoneNum(phone).isRight{
            Message.message(text: "手机号不符合规则")
            return
        }
        
        guard let token = AppUserService.currentUser?.cloudToken else {
            Message.message(text: "无法发送短信验证码")
            return
        }
        
        ActivityIndicator.startActivityIndicatorAnimation()
        GetSmsCodeAPI.init(phoneNumber: phone,type:type,wechatToken:token).startRequestJSONCompletionHandler { (response) in
            if  response.error == nil{
                let responseDic = response.value as! NSDictionary
                let code = responseDic["code"] as? Int
                if code == 1 {
                    ActivityIndicator.stopActivityIndicatorAnimation()
                    callback()
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
    
    func sendMailCodeAction(mail:String?,type:SendCodeType,callback:@escaping (()->())){
        ActivityIndicator.startActivityIndicatorAnimation()
        guard let email = mail else {
            Message.message(text: "邮箱不能为空")
            return
        }
        if !Validate.email(email).isRight{
            Message.message(text: "邮箱格式不正确")
        }
        GetMailCodeAPI.init(mail: email,type:type).startRequestJSONCompletionHandler { (response) in
            ActivityIndicator.stopActivityIndicatorAnimation()
            if  response.error == nil{
                let responseDic = response.value as! NSDictionary
                let code = responseDic["code"] as? Int
                if code == 1 {
                    return callback()
                }else{
                    if let message = ErrorTools.responseErrorData(response.data){
                        Message.message(text:"error: code:\(code!) message:\(message)")
                    }
                }
            }else{
                // error
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
    
    func getMailCodeTicket(sendCodeType:SendCodeType, closure:@escaping (_ ticket:String)->()){
        guard let mail = self.mail else {
            return
        }
        guard let code = self.inputTextField.text else {
            return
        }
        
        ActivityIndicator.startActivityIndicatorAnimation()
        let request = MailCodeTicket.init(mail:mail, code: code,type:sendCodeType)
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
                guard let mailCodeTicket = rootDic["data"] as? String else{
                    return
                }
                
                return closure(mailCodeTicket)
            }
        }
    }
    
    @objc func buttonDidClicked(_ sender:UIButton){
        
    }
    
    @objc func nextButtonTap(_ sender:UIButton){
        switch nextState {
        case .bindEmail?:
            self.getSmsCodeTicket { [weak self](ticket) in
                let bindEmailVC =  MyBindEmailViewController.init(style: NavigationStyle.whiteWithoutShadow)
                self?.navigationController?.pushViewController(bindEmailVC, animated: true)
            }
        case .exchangeEmail?:
            self.mailAction(method: .delete) { [weak self] in
                let bindEmailVC =  MyBindEmailViewController.init(style: NavigationStyle.whiteWithoutShadow)
                self?.navigationController?.pushViewController(bindEmailVC, animated: true)
            }
        case .emailCodeVerification?:
            self.getSmsCodeTicket { [weak self] (ticket) in
                guard let mail = self?.mail else{
                    Message.message(text: LocalizedString(forKey: "无法发送验证码"))
                    return
                }
                
                self?.sendMailCodeAction(mail: mail, type: .unbind, callback: { [weak self] in
                     let mailVerificationCodeVC =  MyVerificationCodeViewController.init(style: .whiteWithoutShadow,state:.email,nextState:.exchangeEmail,codeType:.unbind,mail:mail)
                    self?.navigationController?.pushViewController(mailVerificationCodeVC, animated: true)
                })
            }
            
        case .passwordEmailCodeVerification?:
            self.getSmsCodeTicket { [weak self] (ticket) in
                guard let mail = self?.mail else{
                    Message.message(text: LocalizedString(forKey: "无法发送验证码"))
                    return
                }
                
                var verificationCodeVC =  MyVerificationCodeViewController.init(style: .whiteWithoutShadow,state:.email,nextState:.resetPassword,codeType:.password,mail:mail)
                
                if AppUserService.currentUser?.safety?.intValue == 1 {
                    verificationCodeVC =  MyVerificationCodeViewController.init(style: .whiteWithoutShadow,state:.email,nextState:.resetPassword,codeType:.password,phone:(self?.phoneNumber)!,mail:mail,phoneTicket:ticket)
                 }
                self?.sendMailCodeAction(mail: mail, type: .password, callback: { [weak self] in
                    self?.navigationController?.pushViewController(verificationCodeVC, animated: true)
                })
            }
        case .bindPhone?:
            let changePhoneNumberViewController =  MyChangePhoneNumberViewController.init(style: NavigationStyle.whiteWithoutShadow)
            self.navigationController?.pushViewController(changePhoneNumberViewController, animated: true)
        case .changePassword?:
            let changePasswordViewController =  MyChangePasswordViewController.init(style: NavigationStyle.whiteWithoutShadow)
            self.navigationController?.pushViewController(changePasswordViewController, animated: true)
            
        case .resetPassword?:
            if self.mail == nil{
                self.getSmsCodeTicket { [weak self] (ticket) in
                    self?.resetPasswordPushAction(phoneTicket: ticket)
                }
            }else if self.phoneNumber == nil{
                self.getMailCodeTicket(sendCodeType: .password) { [weak self] (ticket) in
                    self?.resetPasswordPushAction(mailTicket:ticket)
                }
            }
            if AppUserService.currentUser?.safety?.intValue == 1{
                guard let phoneTicket = self.phoneTicket else{
                    return
                }
                self.getMailCodeTicket(sendCodeType: .password) { [weak self] (ticket) in
                    self?.resetPasswordPushAction(phoneTicket:phoneTicket,mailTicket:ticket)
                }
            }
        case .setSamba?:
            let sambaSetPasswordViewController =  DeviceSambaSetPasswordViewController.init(style: NavigationStyle.whiteWithoutShadow)
            self.navigationController?.pushViewController(sambaSetPasswordViewController, animated: true)
        case .bindEmailComplete?:
            self.mailAction(method: .post) { [weak self] in
                Message.message(text: LocalizedString(forKey: "绑定邮箱成功"))
                self?.navigationController?.popToRootViewController(animated: true)
            }
        default:
            break
        }
    }
    
    func resetPasswordPushAction(phoneTicket:String? = nil ,mailTicket:String? = nil){
        let resetPasswordViewController =  MyResetPasswordViewController.init(style: NavigationStyle.whiteWithoutShadow,phoneTicket: phoneTicket,mailTicket:mailTicket)
        self.navigationController?.pushViewController(resetPasswordViewController, animated: true)
    }
    
    @objc func verificationCodeButtonTap(_ sender:UIButton){
        // 启动倒计时
        
        guard let sendCodeType = self.sendCodeType else {
            Message.message(text: "无法发送验证码")
            return
        }
        
        if self.state == .email{
            self.sendMailCodeAction(mail: self.inputTextField.text, type: sendCodeType) { [weak self] in
                self?.isCounting = true
            }
            return
        }
        sendCodeAction(type: sendCodeType) { [weak self] in
            self?.isCounting = true
        }
    }
    
    @objc func updateTime(_ sender:Timer){
        remainingSeconds -= 1
    }


    //键盘弹出监听
    @objc func keyboardShow(noti: Notification)  {
        if self.state == .email{
        }
        guard let userInfo = noti.userInfo else {return}
        guard let keyboardRect = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else{return}
        //获取键盘弹起的高度
        let keyboardTopYPosition =  keyboardRect.origin.y
        let duration = noti.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        
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
    
    lazy var titleLabel:UILabel = { [weak self]  in
        let label = UILabel.initTitleLabel(color: DarkGrayColor, text: LocalizedString(forKey: "输入验证码"))
        label.frame = CGRect(x: MarginsWidth, y: MarginsWidth + MDCAppNavigationBarHeight , width: __kWidth - MarginsWidth*2, height: 48)
        return label
    }()
    
    lazy var detailLabel:UILabel = { [weak self]  in
        let label = UILabel.initDetailTitleLabel(text:LocalizedString(forKey: ""))
        label.frame = CGRect(x: MarginsWidth, y: (self?.titleLabel.bottom)! + MarginsWidth , width: __kWidth - MarginsWidth*2, height: 14)
        return label
    }()
    
    lazy var inputTextField: UITextField = { [weak self] in
        let textField = UITextField.init(frame: CGRect(x: 0, y: (self?.detailLabel.bottom)! + 32, width: __kWidth, height: textFieldHeight))
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 114, height:textFieldHeight))
        let textLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 96, height: view.height))
        textLabel.textColor = DarkGrayColor
        textLabel.font = UIFont.systemFont(ofSize: 14)
        textLabel.textAlignment = .center
        textLabel.text = LocalizedString(forKey: "验证码")
        view.addSubview(textLabel)
        
        let separate = UIView.init(frame: CGRect(x: textLabel.right, y: 0, width: 1, height: view.height))
        separate.backgroundColor = Gray6Color
        view.addSubview(separate)
        
        textField.leftView = view
        textField.leftViewMode = .always
        textField.tintColor = COR1
        textField.font = UIFont.systemFont(ofSize: 21)
        textField.placeholder = LocalizedString(forKey: "验证码")
        textField.delegate = self
        textField.layer.borderColor = Gray6Color.cgColor
        textField.layer.borderWidth = 1.0
        
        textField.rightViewMode = .always
        return textField
        }()
    
    lazy var sendButton: UIButton = { [weak self] in
        let button = UIButton.init(type: .custom)
        let text = LocalizedString(forKey: "获取验证码")
        let font = UIFont.systemFont(ofSize: 14)
        let width:CGFloat = labelWidthFrom(title: text, font: font) + 3
        button.frame = CGRect(x: (self?.inputTextField.width)! - MarginsWidth - width, y: (self?.inputTextField.top)!, width: width, height: textFieldHeight)
        button.setTitle(text, for: UIControlState.normal)
        button.titleLabel?.font = font
        button.setTitleColor(COR1, for: UIControlState.normal)
        button.setTitleColor(Gray38Color, for: UIControlState.disabled)
        button.addTarget(self, action: #selector(verificationCodeButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton.init(type: .custom)
        let width:CGFloat = 40
        button.frame = CGRect(x: __kWidth - MarginsWidth - width , y: __kHeight - MarginsWidth - width, width: width, height: width)
        button.setImage(UIImage.init(named: "next_button_arrow_white.png"), for: UIControlState.normal)
        button.backgroundColor =  COR1.withAlphaComponent(0.26)
        button.isEnabled = false
        button.layer.masksToBounds = true
        button.layer.cornerRadius = width/2
        button.addTarget(self, action: #selector(nextButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        return button
    }()
}

extension MyVerificationCodeViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let rawText = textField.text else {
            return true
        }
        
        let fullString = NSString(string: rawText).replacingCharacters(in: range, with: string)
        if fullString.count >= codeLimit {
            nextButtonEnableStyle()
        }else{
            nextButtonDisableStyle()
        }
        return true
    }
}

//extension MyVerificationCodeViewController:KeyBoardViewDelegate{
//    func keyboard(_ keyboard: KeyBoardView!, didClickTextButton textBtn: UIButton!, string: NSMutableString!) {
//        if let textString = string as String?{
//            self.inputTextField.text = textString
//            if self.inputTextField.text?.count ?? 0 >= codeLimit{
//                nextButtonEnableStyle()
//            }else{
//                nextButtonDisableStyle()
//            }
//        }
//    }
//}
