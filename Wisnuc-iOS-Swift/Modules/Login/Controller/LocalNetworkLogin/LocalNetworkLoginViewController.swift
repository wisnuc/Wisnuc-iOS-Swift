//
//  LocalNetworkLoginViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/18.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents

class LocalNetworkLoginViewController: BaseViewController {
    override func willDealloc() -> Bool {
        return false
    }
    @IBOutlet weak var mainbackgroudView: UIView!
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var passwordTextField: MDCTextField!
    @IBOutlet weak var loginButton: MDCButton!
    @IBOutlet weak var forgetPasswordHelpButton: UIButton!
    @IBOutlet weak var forgetPasswordButton: UIButton!
    @IBOutlet weak var help1Label: UILabel!
    @IBOutlet weak var help2Label: UILabel!
    @IBOutlet weak var eyeButton: UIButton!
    var textFieldControllerPassword:MDCTextInputControllerUnderline?
    var name:String?
    var model:CloadLoginUserRemotModel?
    init(model:CloadLoginUserRemotModel) {
        super.init()
        self.name = model.username ?? "WISNUC"
        self.model = model
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(className()) deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMainUI()
        setDetailsUI()
        setData()
    }
    
    func setMainUI(){
        title = LocalizedString(forKey: "局域网设备")
        stationNameLabel.text = model?.name ?? "WISNUC Station"
        detailLabel.text = "W215i"
        mainbackgroudView.backgroundColor = SkyBlueColor
        appBar.navigationBar.backgroundColor = SkyBlueColor
        appBar.headerViewController.headerView.backgroundColor = SkyBlueColor
        appBar.navigationBar.leftBarButtonItem = UIBarButtonItem.init(image: MDCIcons.imageFor_ic_arrow_back()?.byTintColor(UIColor.white), style: UIBarButtonItemStyle.plain, target: self, action: #selector(backButtonTap(_ :)))
    }
    
    func setDetailsUI(){
        stationNameLabel.font = BoldBigTitleFont
        detailLabel.font = BoldMiddleTitleFont
        userNameLabel.font = BoldMiddlePlusTitleFont
        userNameLabel.textColor = DarkGrayColor
        
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self as UITextFieldDelegate
        passwordTextField.returnKeyType = UIReturnKeyType.done
        passwordTextField.cursorColor = COR1
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.clearButtonMode = UITextFieldViewMode.never
        if #available(iOS 10.0, *) {
            passwordTextField.adjustsFontForContentSizeCategory = true
        } else {
            // Fallback on earlier versions
            passwordTextField.mdc_adjustsFontForContentSizeCategory = true
        }
        self.textFieldControllerPassword = MDCTextInputControllerUnderline.init(textInput: passwordTextField)
        self.textFieldControllerPassword?.isFloatingEnabled = false
        self.textFieldControllerPassword?.placeholderText = LocalizedString(forKey: "password_text")
        self.textFieldControllerPassword?.activeColor = SkyBlueColor
        self.textFieldControllerPassword?.characterCountMax = UInt(PasswordMax)
        
        eyeButton.addTarget(self, action: #selector(eyeButtonClick(_ :)), for: UIControlEvents.touchUpInside)
        
        loginButton.setBackgroundColor(SkyBlueColor)
        loginButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        loginButton.addTarget(self, action: #selector(loginButtonClick(_ :)), for: UIControlEvents.touchUpInside)
        
        forgetPasswordButton.titleLabel?.font = SmallTitleFont
        forgetPasswordButton.setTitleColor(DarkGrayColor, for: UIControlState.normal)
        forgetPasswordButton.backgroundColor = UIColor.clear
        forgetPasswordButton.addTarget(self, action: #selector(forgetPasswordTap(_ :)), for: UIControlEvents.touchUpInside)
        forgetPasswordHelpButton.addTarget(self, action: #selector(forgetPasswordTap(_ :)), for: UIControlEvents.touchUpInside)
        
        help1Label.font = SmallTitleFont
        help2Label.font = SmallTitleFont
        help1Label.isHidden = true
        help2Label.isHidden = true
        help1Label.textColor = LightGrayColor
        help2Label.textColor = LightGrayColor
    }
    
    func setData(){
        userNameLabel.text = name ?? "WISNUC"
        loginButton.setTitle(LocalizedString(forKey: "login"), for: UIControlState.normal)
        forgetPasswordButton.setTitle(LocalizedString(forKey: "forget_password"), for: UIControlState.normal)
        help1Label.text = LocalizedString(forKey: "1.请将设备接入Internet并使用微信登录")
        help2Label.text = LocalizedString(forKey: "2.请联系设备管理员重置密码")
    }
    
    @objc func backButtonTap(_ sender:UIBarButtonItem){
        self.dismiss(animated: true) {
            
        }
    }
    
    @objc func eyeButtonClick(_ sender:UIButton){
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            passwordTextField.isSecureTextEntry = false
        }else{
            passwordTextField.isSecureTextEntry = true
        }
    }
    
    @objc func forgetPasswordTap(_ sender:UIButton){
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            help1Label.isHidden = false
            help2Label.isHidden = false
        }else{
            help1Label.isHidden = true
            help2Label.isHidden = true
        }
    }
    
    @objc func loginButtonClick(_ sender:UIButton){
        if passwordTextField.text == nil || passwordTextField.text?.count == 0{
            Message.message(text: "密码不能为空")
        }
        self.view.endEditing(true)
        sender.isUserInteractionEnabled = false
        ActivityIndicator.startActivityIndicatorAnimation()
        let authString = "\(String(describing: (model?.uuid!)!)):\(isNilString(passwordTextField.text) ? "" : passwordTextField.text!)"
        let basicAuth = authString.toBase64()
        let url = "http://\(String(describing: (model?.LANIP!)!)):3000"

        AppService.sharedInstance().loginAction(model: model!, url: url, basicAuth: basicAuth) { [weak self] (error, user) in
            if error == nil && user != nil{
                AppUserService.setCurrentUser(user)
                AppUserService.synchronizedCurrentUser()
                AppNetworkService.networkState = .local
                self?.dismiss(animated: true, completion: {
                    appDelegate.setRootViewController()
                })
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
                }
            }
            
            ActivityIndicator.stopActivityIndicatorAnimation()
            sender.isUserInteractionEnabled = true
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LocalNetworkLoginViewController:UITextFieldDelegate{
    
}

