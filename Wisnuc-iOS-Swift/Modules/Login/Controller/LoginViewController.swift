//
//  LoginViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/8/28.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

enum EditingState {
    case editing
    case endEditing
}

@objc protocol LoginViewControllerDelegate {
    func wechatLogin()
}

class LoginViewController: BaseViewController {
    let phoneNumberLimitCount = 11
    var phoneNumberIsRight = false
    weak var delegate:LoginViewControllerDelegate?
    var textFieldControllerPhoneNumber:MDCTextInputControllerUnderline?
    var alertView:TipsAlertView?
    var editingState:EditingState?{
        didSet{
            if editingState == .editing{
//               edtingAction()
            }else{
                
            }
        }
    }
    override init(style: NavigationStyle) {
        super.init(style: style)
        self.prepareNavigationBar()
        self.prepareNotification()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("\(className()) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = COR1
        self.view.addSubview(titleLabel)
        self.titleLabel.text = LocalizedString(forKey: "登录")
        self.view.addSubview(phoneNumberTitleLabel)
        self.view.addSubview(phoneNumberTextFiled)
      
        self.setTextFieldController()
        self.view.addSubview(nextButton)
        self.view.addSubview(weChatLoginButton)
        self.phoneNumberTextFiled.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.alertView != nil {
            self.alertView?.dismiss()
        }
        self.view.endEditing(true)
    }
    
    func edtingAction(){
        UIView.animate(withDuration: 0.5) {
           self.nextButton.center = CGPoint(x: self.nextButton.center.x, y: kIQUseDefaultKeyboardDistance + 20)
        }
    }
    
    func prepareNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(note:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //键盘即将隐藏
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHidden(note:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func prepareNavigationBar(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: MDCIcons.imageFor_ic_arrow_back()?.byTintColor(UIColor.white), style: UIBarButtonItemStyle.plain, target: self, action: #selector(backButtonTap(_ :)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: LocalizedString(forKey: "忘记密码"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(forgetPwdTap(_ :)))
    }
    
    func setTextFieldController(){
        self.textFieldControllerPhoneNumber = MDCTextInputControllerUnderline.init(textInput: phoneNumberTextFiled)
        self.textFieldControllerPhoneNumber?.isFloatingEnabled = false
        //        self.textFieldControllerPhoneNumber?.placeholderText = LocalizedString(forKey: "password_text")
        self.textFieldControllerPhoneNumber?.normalColor = UIColor.white.withAlphaComponent(0.38)
        self.textFieldControllerPhoneNumber?.activeColor = .white
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
    
    func nextButtonDisableStyle(){
        self.nextButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        self.nextButton.isEnabled = false
        self.phoneNumberTextFiled.rightView = nil
    }
    
    func nextButtonEnableStyle(){
        self.nextButton.backgroundColor = UIColor.white
        self.nextButton.isEnabled = true
        self.phoneNumberTextFiled.rightView = self.rightView(type: RightViewType.right)
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
            self.weChatLoginButton.center = CGPoint(x: self.weChatLoginButton.center.x, y:self.weChatLoginButton.center.y - alertView.height)
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
        var weChatLoginButtonCenter = CGPoint(x: self.weChatLoginButton.center.x, y: keyboardTopYPosition - 36)
        if  is47InchScreen {
            nextButtonCenter  = CGPoint(x: self.nextButton.center.x, y: keyboardTopYPosition)
            weChatLoginButtonCenter = CGPoint(x: self.weChatLoginButton.center.x, y: keyboardTopYPosition)
        }
    
        UIView.animate(withDuration: duration) {
            self.nextButton.center = nextButtonCenter
            self.weChatLoginButton.center = weChatLoginButtonCenter
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
            self.weChatLoginButton.center = CGPoint(x: self.weChatLoginButton.center.x, y: keyboardTopYPosition - MarginsWidth - self.nextButton.height/2)
        }
    }
    
    @objc func forgetPwdTap(_ sender:UIBarButtonItem){
        let nextViewController = LoginNextStepViewController.init(titleString: LocalizedString(forKey: "忘记密码"), detailTitleString:LocalizedString(forKey: "如果你在“账户安全”中设置了双重身份认证，\n需要通过手机和邮箱验证"), state: .forgetPwd,smsCodeType:.password)
        nextViewController.modalTransitionStyle = .crossDissolve
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @objc func backButtonTap(_ sender:UIBarButtonItem){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func weChatLoginButtonClick(_ sender:MDBaseButton){
        self.presentingViewController?.dismiss(animated: true, completion: { [weak self] in
            self?.delegate?.wechatLogin()
        })
    }
    
    @objc func rightViewTap(_ gestrue:UIGestureRecognizer){
       
    }
    
    @objc func nextButtontTap(_ sender:MDCFloatingButton){
        self.phoneNumberTextFiled.resignFirstResponder()
      
        if isNilString(self.phoneNumberTextFiled.text)  {
            self.alertError(errorText: LocalizedString(forKey: "手机号不能为空"))
            return
        }else if !Validate.phoneNum(self.phoneNumberTextFiled.text!).isRight{
            self.alertError(errorText: LocalizedString(forKey:"请输入正确的手机号"))
            return
        }
        
        if let phone = self.phoneNumberTextFiled.text{
            let loginPasswordVC = LoginInputPasswordViewController.init(style: .mainTheme, phone: phone)
            self.navigationController?.pushViewController(loginPasswordVC, animated: true)
        }

    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: MarginsWidth, y: MDCAppNavigationBarHeight + 25, width: __kWidth - MarginsWidth*2 , height: 28))
        label.font = UIFont.systemFont(ofSize: 28)
        label.textColor = .white
        return label
    }()
    
//    lazy var detailTitleLabel: UILabel = {
//        let label = UILabel.init(frame: CGRect.init(x: MarginsWidth, y: titleLabel.bottom + MarginsWidth, width: __kWidth - MarginsWidth*2 , height: 28))
//        label.font = UIFont.boldSystemFont(ofSize: 14)
//        label.textColor = .white
//        label.numberOfLines = 0
//        return label
//    }()
    
    lazy var phoneNumberTitleLabel: UILabel = {  [weak self] in
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: (self?.titleLabel.bottom)! + 46, width: __kWidth - MarginsWidth*2, height: 12))
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.text = LocalizedString(forKey: "手机号")
        return label
    }()
    
    lazy var phoneNumberTextFiled: MDCTextField = {  [weak self] in
        let textInput = MDCTextField.init(frame: CGRect(x: MarginsWidth, y: (self?.phoneNumberTitleLabel.bottom)! + MarginsWidth, width: __kWidth - MarginsWidth*2, height: 80))
        textInput.leftViewMode = .always
        textInput.keyboardType = .phonePad
        textInput.textColor = .white
        textInput.font = UIFont.systemFont(ofSize: 18)
        textInput.leftView = self?.leftView(image: UIImage.init(named: "86.png"))
        if #available(iOS 10.0, *) {
            textInput.adjustsFontForContentSizeCategory = true
        } else {
            textInput.mdc_adjustsFontForContentSizeCategory = true
        }
        textInput.clearButtonMode = .never
        textInput.rightViewMode = .always
        textInput.delegate = self
        if is47InchScreen{
            textInput.keyboardDistanceFromTextField = 160
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
    
    lazy var weChatLoginButton: MDBaseButton = { [weak self] in
        let ButtonHeight:CGFloat = 32
        let innerButton = MDBaseButton.init(frame: CGRect(x: MarginsWidth, y: __kHeight - MarginsWidth - ButtonHeight, width: 100, height: ButtonHeight))
        innerButton.backgroundColor = COR1
        innerButton.layer.cornerRadius = ButtonHeight/2
        innerButton.setBorderColor(UIColor.white, for: UIControlState.normal)
        innerButton.setBorderWidth(1, for: UIControlState.normal)
        innerButton.setTitle(LocalizedString(forKey: "微信登录"), for: UIControlState.normal)
        innerButton.addTarget(self, action: #selector(weChatLoginButtonClick(_ :)), for: UIControlEvents.touchUpInside)
        return innerButton
        }()
}

extension LoginViewController:TipsAlertViewDelegate{
    func alertDismiss(animateDuration: TimeInterval) {
        UIView.animate(withDuration: animateDuration) {
            self.nextButton.center = CGPoint(x: self.nextButton.center.x, y: __kHeight - MarginsWidth - self.nextButton.height/2)
            self.weChatLoginButton.center = CGPoint(x: self.weChatLoginButton.center.x, y: __kHeight - MarginsWidth - self.weChatLoginButton.height/2)
        }
    }
}

extension LoginViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let rawText = textField.text else {
            return true
        }
        
        let fullString = NSString(string: rawText).replacingCharacters(in: range, with: string)
//        print(fullString)
        if textField == phoneNumberTextFiled {
            if  fullString.count > phoneNumberLimitCount {
                textField.text = textField.text?.subString(to: phoneNumberLimitCount)
                return false
            }
            if Validate.phoneNum(fullString).isRight {
                self.nextButtonEnableStyle()
            }else{
                self.nextButtonDisableStyle()
            }
        }
       
        return true
    }
}

extension LoginViewController:UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = LoginTransition()
        return transition
    }
}

extension LoginViewController:LoginSelectionDeviceViewControllerDelegte{
    func loginFinish(user: User, stationModel: Any) {
        ActivityIndicator.startActivityIndicatorAnimation()
            let model = stationModel as! StationsInfoModel
            AppService.sharedInstance().loginAction(stationModel: model, orginTokenUser: user) { (error, userData) in
                if error == nil && userData != nil{
                    AppUserService.isUserLogin = true
                    AppUserService.isStationSelected = true
                    AppUserService.setCurrentUser(userData)
                    AppUserService.currentUser?.isSelectStation = NSNumber.init(value: AppUserService.isStationSelected)
                    AppUserService.synchronizedCurrentUser()
                    if let sn = model.sn,let cloudToken = userData?.cloudToken{
                        AppService.sharedInstance().saveUserUsedDeviceInfo(sn: sn, token: cloudToken, closure: {})
                    }
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
    }
}
