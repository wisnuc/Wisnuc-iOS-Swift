//
//  MyResetPasswordViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/15.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class MyResetPasswordViewController: BaseViewController {
    var newPasswordTextFieldController:MDCTextInputControllerUnderline?
    var confirmPasswordTextFieldController:MDCTextInputControllerUnderline?
    override func viewDidLoad() {
        super.viewDidLoad()
        setContentFrame()
        self.view.addSubview(titleLabel)
        self.view.addSubview(detailLabel)
        
        self.view.addSubview(newPasswordInputTextField)
        self.view.addSubview(confirmPasswordInputTextField)
        preparerTextFieldController()
        
        self.view.addSubview(confirmButton)
        
        // Do any additional setup after loading the view.
    }
    
    
    func preparerTextFieldController() {
   
        self.newPasswordTextFieldController = MDCTextInputControllerUnderline.init(textInput: newPasswordInputTextField)
        self.newPasswordTextFieldController?.isFloatingEnabled = true
        self.newPasswordTextFieldController?.normalColor = Gray6Color
        self.newPasswordTextFieldController?.activeColor =  COR1
        self.newPasswordTextFieldController?.placeholderText = LocalizedString(forKey: "新密码")
        self.newPasswordTextFieldController?.floatingPlaceholderActiveColor = COR1
        
        
        self.confirmPasswordTextFieldController = MDCTextInputControllerUnderline.init(textInput: confirmPasswordInputTextField)
        self.confirmPasswordTextFieldController?.isFloatingEnabled = true
        self.confirmPasswordTextFieldController?.normalColor = Gray6Color
        self.confirmPasswordTextFieldController?.activeColor =  COR1
        self.confirmPasswordTextFieldController?.placeholderText = LocalizedString(forKey: "确认密码")
        self.confirmPasswordTextFieldController?.floatingPlaceholderActiveColor = COR1
    }
    
    func setContentFrame(){
        titleLabel.frame = CGRect(x: MarginsWidth, y: MarginsWidth + MDCAppNavigationBarHeight , width: __kWidth - MarginsWidth*2, height: 48)
        detailLabel.frame = CGRect(x: MarginsWidth, y: titleLabel.bottom + MarginsWidth , width: __kWidth - MarginsWidth*2, height: 28)
        
    }
    
    @objc func confirmButtonTap(_ sender:UIButton){
        self.alertController(title: "密码修改 成功", message: "可用 139****2222加密码直接登录", okActionTitle: "重新登录") { (alertAction) in
            
        }
    }
    
    lazy var titleLabel = UILabel.initTitleLabel(color: DarkGrayColor, text: LocalizedString(forKey: "设置新密码"))
    lazy var detailLabel = UILabel.initDetailTitleLabel(text:LocalizedString(forKey: "为了账号安全，建议您设置安全性较强的密码  \n 如多字符的数字与字母，符号的组合"))
    
    lazy var newPasswordInputTextField: MDCTextField = { [weak self] in
        let textInput = MDCTextField.init(frame: CGRect(x: MarginsWidth, y: (self?.detailLabel.bottom)! + 32, width: __kWidth - MarginsWidth*2, height: 60))
        textInput.font = UIFont.systemFont(ofSize: 16)
        textInput.clearButtonMode = .never
        if #available(iOS 10.0, *) {
            textInput.adjustsFontForContentSizeCategory = true
        } else {
            textInput.mdc_adjustsFontForContentSizeCategory = true
        }
        textInput.delegate = self
        return textInput
        }()
    
    lazy var confirmPasswordInputTextField: MDCTextField = { [weak self] in
        let textInput = MDCTextField.init(frame: CGRect(x: MarginsWidth, y: (self?.newPasswordInputTextField.bottom)! + 32, width: __kWidth - MarginsWidth*2, height: 60))
        textInput.font = UIFont.systemFont(ofSize: 16)
        textInput.clearButtonMode = .never
        if #available(iOS 10.0, *) {
            textInput.adjustsFontForContentSizeCategory = true
        } else {
            textInput.mdc_adjustsFontForContentSizeCategory = true
        }
        textInput.delegate = self
        return textInput
        }()
    
    lazy var confirmButton: UIButton = { [weak self] in
        let button = UIButton.init(frame: CGRect(x: MarginsWidth, y: (self?.confirmPasswordInputTextField.bottom)! + 32, width:__kWidth - MarginsWidth*2 , height: 44))
        button.setTitle(LocalizedString(forKey: "确定"), for: UIControlState.normal)
        button.setTitleColor(.white, for: UIControlState.normal)
        button.setTitleColor(COR1, for: UIControlState.disabled)
        button.setBackgroundImage(UIImage.init(color: COR1), for: UIControlState.normal)
        button.setBackgroundImage(UIImage.init(color: Gray12Color), for: UIControlState.disabled)
        button.layer.cornerRadius = 2
        button.clipsToBounds = true
        
        button.addTarget(self, action: #selector(confirmButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        return button
        }()
    
}

extension MyResetPasswordViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let rawText = textField.text else {
            return true
        }
        
        let fullString = NSString(string: rawText).replacingCharacters(in: range, with: string)
        if fullString.count > 0 && checkIsPhoneNumber(number: fullString){
            //            nextButtonEnableStyle()
        }else{
            //            nextButtonDisableStyle()
        }
        return true
    }
    
}
