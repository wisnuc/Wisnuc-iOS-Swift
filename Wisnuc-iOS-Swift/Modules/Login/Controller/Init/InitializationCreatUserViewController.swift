//
//  InitializationCreatUserViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/20.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents

class InitializationCreatUserViewController: BaseViewController {
//    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var nextButton: MDCButton!
    @IBOutlet weak var previousButton: MDCButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var passwordTextField: MDCTextField!
    @IBOutlet weak var confirmPasswordTextField: MDCTextField!
    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    var textFieldControllerPassword:MDCTextInputControllerUnderline?
    var textFieldControllerConfirmPassword:MDCTextInputControllerUnderline?
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
        baseSetting()
    }
    
    func baseSetting(){
        bgView.backgroundColor = COR1
        titleLable.textColor = LightGrayColor
        nameTextField.text = "Mark"
//        errorLabel.textColor = RedErrorColor
        setTextField()
        setButton()
        userImageView.backgroundColor = SkyBlueColor
        userImageView.layer.masksToBounds = true
        userImageView.layer.cornerRadius = userImageView.width/2
        userImageView.layer.borderColor = UIColor.cyan.cgColor
        userImageView.layer.borderWidth = 5
    }
    
    func setData() {
        titleLable.text = LocalizedString(forKey: "设置管理员密码")
//        errorLabel.text = LocalizedString(forKey: "密码不一致")
    }
    
    func setTextField() {
        passwordTextField.clearButtonMode = .never
        passwordTextField.returnKeyType = UIReturnKeyType.next
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
        confirmPasswordTextField.clearButtonMode = .never
        confirmPasswordTextField.returnKeyType = UIReturnKeyType.done
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 10.0, *) {
            passwordTextField.adjustsFontForContentSizeCategory = true
            confirmPasswordTextField.adjustsFontForContentSizeCategory = true
        } else {
            // Fallback on earlier versions
            passwordTextField.mdc_adjustsFontForContentSizeCategory = true
            confirmPasswordTextField.mdc_adjustsFontForContentSizeCategory = true
        }
        
        self.textFieldControllerPassword = MDCTextInputControllerUnderline.init(textInput: passwordTextField)
        passwordTextField.autocapitalizationType = .words
        self.textFieldControllerPassword?.placeholderText = LocalizedString(forKey: "password_text")
        self.textFieldControllerPassword?.activeColor = COR1
        //        self.textFieldControllerPassword?.characterCountMax = UInt(PasswordMax)
        
        self.textFieldControllerConfirmPassword = MDCTextInputControllerUnderline.init(textInput: confirmPasswordTextField)
        confirmPasswordTextField.autocapitalizationType = .words
        self.textFieldControllerConfirmPassword?.placeholderText = LocalizedString(forKey: "再输一遍密码")
        self.textFieldControllerConfirmPassword?.activeColor = COR1
        //        self.textFieldControllerConfirmPassword?.setErrorText(LocalizedString(forKey: "密码不一致"), errorAccessibilityValue: "dasdada")
        //        self.textFieldControllerPassword?.characterCountMax = UInt(PasswordMax)
        textFieldControllerConfirmPassword?.errorColor = RedErrorColor
        //        textFieldControllerConfirmPassword.err
     
    }
    
    func setButton() {
        nextButton.setTitle(LocalizedString(forKey: "next_step"), for: UIControlState.normal)
        nextButton.setBackgroundColor(COR1, for: UIControlState.normal)
        nextButton.setBorderColor(UIColor.black, for: UIControlState.disabled)
        nextButton.setBorderWidth(1, for: UIControlState.disabled)
        
        previousButton.setTitle(LocalizedString(forKey: "previous_step"), for: UIControlState.normal)
        previousButton.setBackgroundColor(COR1, for: UIControlState.normal)
        previousButton.setBorderColor(UIColor.black, for: UIControlState.disabled)
        previousButton.setBorderWidth(1, for: UIControlState.disabled)
    }
    
    func setButtonEnable(button:MDCButton,enable:Bool){
        button.setEnabled(enable, animated: true)
    }
    
    @IBAction func changeNameButtonClick(_ sender: UIButton) {
        
    }
    
    @IBAction func eyeButtonClick(_ sender: UIButton) {
    }
    
    @IBAction func nextButtonClick(_ sender: MDCButton) {
        let finishView = InitLastView.init(state: .succeed , frame: CGRect(x: 0, y: __kHeight, width: self.view.width, height: __kHeight - MDCAppNavigationBarHeight))
        self.view.addSubview(finishView)
        UIView.animate(withDuration: 0.5) {
        finishView.frame = CGRect(x: 0, y:MDCAppNavigationBarHeight , width: self.view.width, height: __kHeight - MDCAppNavigationBarHeight)
        }
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
