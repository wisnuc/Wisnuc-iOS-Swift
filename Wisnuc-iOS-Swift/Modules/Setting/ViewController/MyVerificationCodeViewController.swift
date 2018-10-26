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
    case bindPhone
    case changePassword
    case resetPassword
    case setSamba
}

class MyVerificationCodeViewController: BaseViewController {
    let textFieldHeight:CGFloat = 64
    var countdownTimer: Timer?
    var extrakeyButton:UIButton?
    var remainingSeconds: Int = 0 {
        willSet {
            let text = LocalizedString(forKey: "\(newValue)秒后重新获取")
            sendButton.setTitle(text, for: .normal)
            let font = UIFont.systemFont(ofSize: 14)
            let width:CGFloat = labelWidthFrom(title: text, font: font) + 3
            sendButton.frame = CGRect(x: __kWidth - MarginsWidth - width , y: 0, width:  width, height: textFieldHeight)
            if newValue <= 0 {
                let text = LocalizedString(forKey: "重新获取验证码")
                sendButton.setTitle(text, for: .normal)
                let font = UIFont.systemFont(ofSize: 14)
                let width:CGFloat = labelWidthFrom(title: text, font: font) + 3
                sendButton.frame = CGRect(x: __kWidth - MarginsWidth - width , y: 0, width:  width, height: textFieldHeight)
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
    
    init(style: NavigationStyle,state:MyVerificationCodeViewControllerState,nextState:MyVerificationCodeViewControllerNextState) {
        super.init(style: style)
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
        self.view.addSubview(nicknameTextField)
        nicknameTextField.addSubview(sendButton)
        self.view.addSubview(nextButton)
     
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
        detailLabel.text = "6位验证码已发送至：\n wenshang@163.com(绑定邮箱)"
        detailLabel.frame = CGRect(x: MarginsWidth, y: titleLabel.bottom + MarginsWidth, width: __kWidth - MarginsWidth*2, height: 14*3)
//        let keyboard = em.
//        nicknameTextField.inputViewController = .numberPad
    }
    
    func phoneStateAction(){
        detailLabel.text = "验证码已发送至您的手机号：139****2222"
        detailLabel.frame = CGRect(x: MarginsWidth, y: titleLabel.bottom + MarginsWidth, width: __kWidth - MarginsWidth*2, height: 14)
    }
    
    func emailKeyboardChangeAction(noti:Notification){
        //移除掉原先添加的按钮
        self.extrakeyButton?.removeFromSuperview()
        self.extrakeyButton = nil
        //这几行代码相信看了之前系列博客的读者应该很熟悉了
        var userInfo = noti.userInfo
        let animationDuration = userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0
        let kbEndFrame: CGRect = userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect ?? CGRect.zero
        let kbHeight: CGFloat = kbEndFrame.size.height
        //以下是对添加的X按钮Frame的设置
        let extrakeyButtonX: CGFloat = 6
        let extrakeyButtonW: CGFloat = (__kWidth - 6*4) / 3
        let extrakeyButtonH: CGFloat = (kbHeight - (6 * 4) - 2) / 4
        let extrakeyButtonY: CGFloat = __kHeight - kbHeight - extrakeyButtonH + 2
        //创建“X”按钮，并设置相应的属性
        extrakeyButton = UIButton(frame: CGRect(x: extrakeyButtonX, y: extrakeyButtonY, width: extrakeyButtonW, height: extrakeyButtonH))
        self.extrakeyButton?.addTarget(self, action: #selector(buttonDidClicked(_ :)), for: .touchUpInside)
        self.extrakeyButton?.titleLabel?.font = UIFont.systemFont(ofSize: 27)
        self.extrakeyButton?.setTitle("X", for: .normal)
        self.extrakeyButton?.setTitleColor(UIColor.black, for: .normal)
        self.extrakeyButton?.setBackgroundImage(UIImage.init(color: UIColor.white), for: UIControlState.normal)
        self.extrakeyButton?.setBackgroundImage(UIImage.init(color: UIColor.colorFromRGB(rgbValue: 0x0b8c6d3)), for: UIControlState.highlighted)
        //获取键盘对应的Window(这段代码只在iOS 11上做过测试，还不够严谨)
        let tempWindow: UIWindow? = UIApplication.shared.windows.last
        tempWindow?.addSubview(self.extrakeyButton!)
        //设置动画
        UIView.animate(withDuration: animationDuration, animations: {
            var frame: CGRect = self.extrakeyButton?.frame ?? CGRect.zero
            frame.origin.y = frame.origin.y - kbHeight
            self.extrakeyButton?.frame = frame
        })
    }
    
    @objc func buttonDidClicked(_ sender:UIButton){
        
    }
    
    @objc func nextButtonTap(_ sender:UIButton){
        switch nextState {
        case .bindEmail?:
            let bindEmailVC =  MyBindEmailViewController.init(style: NavigationStyle.whiteWithoutShadow)
            self.navigationController?.pushViewController(bindEmailVC, animated: true)
        case .bindPhone?:
            let changePhoneNumberViewController =  MyChangePhoneNumberViewController.init(style: NavigationStyle.whiteWithoutShadow)
            self.navigationController?.pushViewController(changePhoneNumberViewController, animated: true)
        case .changePassword?:
            let changePasswordViewController =  MyChangePasswordViewController.init(style: NavigationStyle.whiteWithoutShadow)
            self.navigationController?.pushViewController(changePasswordViewController, animated: true)
            
        case .resetPassword?:
            let resetPasswordViewController =  MyResetPasswordViewController.init(style: NavigationStyle.whiteWithoutShadow)
            self.navigationController?.pushViewController(resetPasswordViewController, animated: true)
        case .setSamba?:
            let sambaSetPasswordViewController =  DeviceSambaSetPasswordViewController.init(style: NavigationStyle.whiteWithoutShadow)
            self.navigationController?.pushViewController(sambaSetPasswordViewController, animated: true)
        
        default:
            break
        }
    }
    
    @objc func verificationCodeButtonTap(_ sender:UIButton){
        // 启动倒计时
        isCounting = true
    }
    
    @objc func updateTime(_ sender:Timer){
        remainingSeconds -= 1
    }


    //键盘弹出监听
    @objc func keyboardShow(noti: Notification)  {
        if self.state == .email{
            self.emailKeyboardChangeAction(noti:noti)
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
    
    lazy var nicknameTextField: UITextField = { [weak self] in
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
        button.frame = CGRect(x: (self?.nicknameTextField.width)! - MarginsWidth - width, y: 0, width: width, height: textFieldHeight)
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
        if fullString.count >= 6 {
            nextButtonEnableStyle()
        }else{
            nextButtonDisableStyle()
        }
        return true
    }
}
