//
//  DeviceAaddUserPhoneNumberViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/17.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
enum DeviceAaddUserPhoneNumberViewControllerState {
    case bindFinish
    case binding
}

class DeviceAaddUserPhoneNumberViewController: BaseViewController {
    var phoneNumberTextFieldController:MDCTextInputControllerUnderline?
    var state:DeviceAaddUserPhoneNumberViewControllerState?{
        didSet{
            switch state {
            case .binding?:
                bindingAction()
            case .bindFinish?:
                bindFinishAction()
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContentFrame()
        self.view.addSubview(titleLabel)
        self.view.addSubview(detailLabel)
        self.view.addSubview(textFieldTitleLabel)
        self.view.addSubview(phoneNumberInputTextField)
        preparerTextFieldController()
        
        self.view.addSubview(confirmButton)
        self.view.addSubview(finishImageView)
        self.view.addSubview(finishLabel)
        self.state = .binding
        // Do any additional setup after loading the view.
    }
    
    @objc func rightBarButtonItemTap(_ sender:UIBarButtonItem){
        if  let popViewController  = self.navigationController?.viewControllers.filter({$0 is DeviceUsersManageViewController}){
              self.navigationController?.popToViewController(popViewController[0], animated: true)
        }
    }
    
    func preparerTextFieldController() {
        self.phoneNumberTextFieldController = MDCTextInputControllerUnderline.init(textInput: phoneNumberInputTextField)
        self.phoneNumberTextFieldController?.isFloatingEnabled = false
        self.phoneNumberTextFieldController?.normalColor = Gray6Color
        self.phoneNumberTextFieldController?.activeColor =  COR1
        self.phoneNumberTextFieldController?.placeholderText = LocalizedString(forKey: "手机号")
        self.phoneNumberTextFieldController?.floatingPlaceholderActiveColor = COR1
    }
    
    func bindingAction(){
        textFieldTitleLabel.isHidden = false
        phoneNumberInputTextField.isHidden = false
        confirmButton.isHidden = false
        
        finishImageView.isHidden = true
        finishLabel.isHidden = true
        self.navigationItem.rightBarButtonItem = nil
        phoneNumberInputTextField.becomeFirstResponder()
    }
    
    func bindFinishAction(){
        textFieldTitleLabel.isHidden = true
        phoneNumberInputTextField.isHidden = true
        confirmButton.isHidden = true
        
        finishImageView.isHidden = false
        finishLabel.isHidden = false
        appBar.navigationBar.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: LocalizedString(forKey: "确定"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightBarButtonItemTap(_ :)))
    }
    
    func nextButtonDisableStyle(){
        self.confirmButton.isEnabled = false
    }
    
    func nextButtonEnableStyle(){
        self.confirmButton.isEnabled = true
    }
    
    func setContentFrame(){
        titleLabel.frame = CGRect(x: MarginsWidth, y: MarginsWidth + MDCAppNavigationBarHeight , width: __kWidth - MarginsWidth*2, height: 21)
        detailLabel.frame = CGRect(x: MarginsWidth, y: titleLabel.bottom + MarginsWidth , width: __kWidth - MarginsWidth*2, height: 12)
    }
    
    @objc func confirmButtonTap(_ sender:UIButton){
        self.view.endEditing(true)
        guard let stationId = AppUserService.currentUser?.stationId else { return }
        guard let phone = self.phoneNumberInputTextField.text else { return }
        ActivityIndicator.startActivityIndicatorAnimation()
        let requset = StationUserAPI.init(stationId: stationId, type: .add, phone: phone)
        requset.startRequestJSONCompletionHandler { (response) in
            ActivityIndicator.stopActivityIndicatorAnimation()
            if let error =  response.error{
                Message.message(text: error.localizedDescription)
            }else{
                if let dic = response.value as? NSDictionary{
                     if let code =  dic["code"] as? Int{
                        if code == ErrorCode.Request.ShareUserExist{
                            Message.message(text: ErrorLocalizedDescription.Request.ShareUserExist)
                            return
                        }
                    }
                }
                
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    Message.message(text: errorMessage)
                    return
                }
                 self.state = .bindFinish
            }
        }
    }
    
    lazy var titleLabel = UILabel.initTitleLabel(color: DarkGrayColor, text: LocalizedString(forKey: "添加用户手机"))
    lazy var detailLabel = UILabel.initDetailTitleLabel(text:LocalizedString(forKey: "添加亲友，共享设备"))
    
    lazy var finishImageView : UIImageView = { [weak self] in
        let imageView = UIImageView.init(frame: CGRect(x: __kWidth/2 - 64/2, y: (self?.detailLabel.bottom)! + 50, width: 64, height: 64))
        imageView.image = UIImage.init(named: "finished.png")
        return imageView
        }()
    
    lazy var finishLabel : UILabel = { [weak self] in
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: (self?.finishImageView.bottom)! + MarginsCloseWidth, width: __kWidth - MarginsWidth*2, height: 16))
        label.textColor = LightGrayColor
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = LocalizedString(forKey: "完成")
        label.textAlignment = .center
        return label
        }()
    
    lazy var textFieldTitleLabel : UILabel = { [weak self] in
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: (self?.detailLabel.bottom)! + 46, width: __kWidth - MarginsWidth*2, height: 12))
        label.textColor = LightGrayColor
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = LocalizedString(forKey: "手机号")
        return label
        }()
    
    lazy var phoneNumberInputTextField: MDCTextField = { [weak self] in
        let textInput = MDCTextField.init(frame: CGRect(x: MarginsWidth, y: (self?.textFieldTitleLabel.bottom)! + 16, width: __kWidth - MarginsWidth*2, height: 40))
        textInput.font = UIFont.systemFont(ofSize: 16)
        textInput.clearButtonMode = .never
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: 24+MarginsWidth, height:24))
        let imageView = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        imageView.image = UIImage.init(named: "phone_icon_textFiled.png")
        view.addSubview(imageView)
        
        textInput.leftView = view
        textInput.leftViewMode = .always
        textInput.keyboardType = .phonePad
        if #available(iOS 10.0, *) {
            textInput.adjustsFontForContentSizeCategory = true
        } else {
            textInput.mdc_adjustsFontForContentSizeCategory = true
        }
        textInput.delegate = self
        return textInput
        }()
    
    lazy var confirmButton: UIButton = { [weak self] in
        let button = UIButton.init(frame: CGRect(x: MarginsWidth, y: (self?.phoneNumberInputTextField.bottom)! + 64, width:__kWidth - MarginsWidth*2 , height: 44))
        button.setTitle(LocalizedString(forKey: "确定"), for: UIControlState.normal)
        button.setTitleColor(.white, for: UIControlState.normal)
        button.setBackgroundImage(UIImage.init(color: COR1), for: UIControlState.normal)
        button.setBackgroundImage(UIImage.init(color: Gray12Color), for: UIControlState.disabled)
        button.layer.cornerRadius = 44/2
        button.clipsToBounds = true
        button.isEnabled = false
        button.addTarget(self, action: #selector(confirmButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        return button
        }()
    
}

extension DeviceAaddUserPhoneNumberViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let rawText = textField.text else {
            return true
        }
        
        let fullString = NSString(string: rawText).replacingCharacters(in: range, with: string)
        if Validate.phoneNum(fullString).isRight{
            nextButtonEnableStyle()
        }else{
            nextButtonDisableStyle()
        }
        return true
    }
    
}


