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

class LoginViewController: BaseViewController {
    var textFieldControllerPhoneNumber:MDCTextInputControllerUnderline?
    var textFieldControllerPassword:MDCTextInputControllerUnderline?
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
        titleLabel.text = LocalizedString(forKey: "登录")
        self.view.addSubview(phoneNumberTitleLabel)
        self.view.addSubview(phoneNumberTextFiled)
        self.view.addSubview(passwordTitleLabel)
        self.view.addSubview(passwordTextFiled)
        setTextFieldController()
        self.view.addSubview(nextButton)
        self.view.addSubview(weChatLoginButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        //        self.textFieldControllerPhoneNumber?.textInsets(UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0))
        
        self.textFieldControllerPassword = MDCTextInputControllerUnderline.init(textInput: passwordTextFiled)
        self.textFieldControllerPassword?.isFloatingEnabled = false
        //        self.textFieldControllerPhoneNumber?.placeholderText = LocalizedString(forKey: "password_text")
        self.textFieldControllerPassword?.normalColor = UIColor.white.withAlphaComponent(0.38)
        self.textFieldControllerPassword?.activeColor = .white
    }
    
    //键盘弹出监听
    @objc func keyboardShow(note: Notification)  {
        guard let userInfo = note.userInfo else {return}
        guard let keyboardRect = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else{return}
        //获取键盘弹起的高度
        let keyboardTopYPosition =  keyboardRect.origin.y
        let duration = note.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
    
        UIView.animate(withDuration: duration) {
            self.nextButton.center = CGPoint(x: self.nextButton.center.x, y: keyboardTopYPosition - 36)
            self.weChatLoginButton.center = CGPoint(x: self.weChatLoginButton.center.x, y: keyboardTopYPosition - 36)
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
        let nextViewController = LoginNextStepViewController.init(titleString: LocalizedString(forKey: "忘记密码"), detailTitleString:LocalizedString(forKey: "请输入您的手机号码来查找账号"), state: .phoneNumber)
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @objc func backButtonTap(_ sender:UIBarButtonItem){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func weChatLoginButtonClick(_ sender:MDBaseButton){
        
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: MarginsWidth, y: MDCAppNavigationBarHeight + 25, width: __kWidth - MarginsWidth*2 , height: 28))
        label.font = UIFont.boldSystemFont(ofSize: 28)
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
        textInput.font = UIFont.systemFont(ofSize: 16)
        let leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: 32, height: 24))
        leftView.backgroundColor = .white
        textInput.leftView = leftView
        if #available(iOS 10.0, *) {
            textInput.adjustsFontForContentSizeCategory = true
        } else {
            textInput.mdc_adjustsFontForContentSizeCategory = true
        }
        return textInput
    }()
    
    lazy var passwordTitleLabel: UILabel = {  [weak self] in
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: (self?.phoneNumberTextFiled.bottom)! + 16, width: __kWidth - MarginsWidth*2, height: 12))
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.text = LocalizedString(forKey: "密码")
        return label
    }()
    
    lazy var passwordTextFiled: MDCTextField = { [weak self] in
        let textInput = MDCTextField.init(frame: CGRect(x: MarginsWidth, y: (self?.passwordTitleLabel.bottom)! + MarginsWidth, width: __kWidth - MarginsWidth*2, height: 80))
        textInput.leftViewMode = .always
        textInput.textColor = .white
        textInput.font = UIFont.systemFont(ofSize: 16)
        textInput.isSecureTextEntry = true
        let leftView = UIView.init(frame: CGRect(x: 0, y: 0, width: 32, height: 24))
        leftView.backgroundColor = .white
        textInput.leftView = leftView
        if #available(iOS 10.0, *) {
            textInput.adjustsFontForContentSizeCategory = true
        } else {
            textInput.mdc_adjustsFontForContentSizeCategory = true
        }
//        textInput.keyboardDistanceFromTextField = 60
        return textInput
    }()
    

    lazy var nextButton: MDCFloatingButton = {
        let button = MDCFloatingButton.init(shape: MDCFloatingButtonShape.default)
        let width:CGFloat = 40
        button.frame = CGRect(x: __kWidth - MarginsWidth - width , y: __kHeight - MarginsWidth - width, width: width, height: width)
        button.setImage(UIImage.init(named: "next_button_arrow"), for: UIControlState.normal)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.4)
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
