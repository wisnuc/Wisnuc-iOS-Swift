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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMainUI()
        setDetailsUI()
        setData()
    }
    
    func setMainUI(){
        title = LocalizedString(forKey: "局域网设备")
        mainbackgroudView.backgroundColor = SkyBlueColor
        appBar.navigationBar.backgroundColor = SkyBlueColor
        appBar.headerViewController.headerView.backgroundColor = SkyBlueColor
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
        userNameLabel.text = "Mark"
        loginButton.setTitle(LocalizedString(forKey: "login"), for: UIControlState.normal)
        forgetPasswordButton.setTitle(LocalizedString(forKey: "forget_password"), for: UIControlState.normal)
        help1Label.text = LocalizedString(forKey: "1.请将设备接入Internet并使用微信登录")
        help2Label.text = LocalizedString(forKey: "2.请联系设备管理员重置密码")
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

