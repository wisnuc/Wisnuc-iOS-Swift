//
//  ConfigNetworkViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/13.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork
enum ConfigNetworkViewControllerState {
    case initialization
    case change
}

class ConfigNetworkViewController: BaseViewController {
    var textFieldControllerNetworkName:MDCTextInputControllerUnderline?
    var textFieldControllerPassword:MDCTextInputControllerUnderline?
    var isNetworkNameTrue = false
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
    
    
    @objc func nextButtontTap(_ sender:MDCFloatingButton){
        self.networkNameTextFiled.resignFirstResponder()
        self.passwordTextFiled.resignFirstResponder()
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark)
        SVProgressHUD.show(withStatus: LocalizedString(forKey: "Wi-Fi配置中"))
        sender.isHidden = true
        DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 3) {
            DispatchQueue.main.async {
                 SVProgressHUD.dismiss()
                let identifyingFromDeviceVC = IdentifyingFromDeviceViewController.init(style: NavigationStyle.whiteWithoutShadow)
                self.navigationController?.pushViewController(identifyingFromDeviceVC, animated: true)
            }
        }
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
                    rightView.image = UIImage.init(named: "down_arrow_gray.png")
                }else{
                    rightView.image = UIImage.init(named: "up_arrow_gray.png")
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
