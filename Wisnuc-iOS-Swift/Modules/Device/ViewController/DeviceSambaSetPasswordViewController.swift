//
//  DeviceSambaSetPasswordViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/18.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
enum DeviceSambaSetPasswordViewControllerState {
    case setFinish
    case setting
}

class DeviceSambaSetPasswordViewController: BaseViewController {
    let textFieldHeight:CGFloat = 64
    var state:DeviceSambaSetPasswordViewControllerState?{
        didSet{
            switch state {
            case .setting?:
                settingAction()
            case .setFinish?:
                setFinishAction()
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
    
        self.view.addSubview(phoneNumberInputTextField)
        
        self.view.addSubview(confirmButton)
        self.view.addSubview(finishImageView)
        self.view.addSubview(finishLabel)
        self.state = .setting
        self.appBar.navigationBar.backItem = UIBarButtonItem.init(image:MDCIcons.imageFor_ic_arrow_back()?.byTintColor(LightGrayColor), style: UIBarButtonItemStyle.plain, target: self, action: #selector(didBackTap(_ :)))
    }
    
    @objc func rightBarButtonItemTap(_ sender:UIBarButtonItem){
        self.state = .setting

    }
    
    @objc func didBackTap(_ sender:UIBarButtonItem){
        if (self.navigationController?.viewControllers.contains(where: {$0 is MyVerificationCodeViewController}))!{
            if  let popViewController  = self.navigationController?.viewControllers.filter({$0 is DeviceSambaSettingViewController}){
                self.navigationController?.popToViewController(popViewController[0], animated: true)
            }else{
                 self.navigationController?.popViewController(animated: true)
            }
        }else{
             self.navigationController?.popViewController(animated: true)
        }
    }
    
    func settingAction(){
     
        phoneNumberInputTextField.isHidden = false
        phoneNumberInputTextField.text = nil
        confirmButton.isHidden = false
        
        finishImageView.isHidden = true
        finishLabel.isHidden = true
        self.navigationItem.rightBarButtonItem = nil
        phoneNumberInputTextField.becomeFirstResponder()
    }
    
    func setFinishAction(){
  
        phoneNumberInputTextField.isHidden = true
        confirmButton.isHidden = true
        
        finishImageView.isHidden = false
        finishLabel.isHidden = false

        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: LocalizedString(forKey: "重置密码"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightBarButtonItemTap(_ :)))
    }
    
    func setContentFrame(){
        titleLabel.frame = CGRect(x: MarginsWidth, y: MarginsWidth + MDCAppNavigationBarHeight , width: __kWidth - MarginsWidth*2, height: 21)
        detailLabel.frame = CGRect(x: MarginsWidth, y: titleLabel.bottom + MarginsWidth , width: __kWidth - MarginsWidth*2, height: 12)
    }
    
    @objc func confirmButtonTap(_ sender:UIButton){
        self.state = .setFinish
        self.view.endEditing(true)
    }
    
    lazy var titleLabel = UILabel.initTitleLabel(color: DarkGrayColor, text: LocalizedString(forKey: "设置SAMBA访问密码"))
    lazy var detailLabel = UILabel.initDetailTitleLabel(text:LocalizedString(forKey: "通过密码可访问个人数据"))
    
    lazy var finishImageView : UIImageView = { [weak self] in
        let imageView = UIImageView.init(frame: CGRect(x: __kWidth/2 - 64/2, y: (self?.detailLabel.bottom)! + 50, width: 64, height: 64))
        imageView.image = UIImage.init(named: "finished.png")
        return imageView
        }()
    
    lazy var finishLabel : UILabel = { [weak self] in
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: (self?.finishImageView.bottom)! + MarginsCloseWidth, width: __kWidth - MarginsWidth*2, height: 16))
        label.textColor = LightGrayColor
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = LocalizedString(forKey: "已设置")
        label.textAlignment = .center
        return label
        }()
    
    lazy var phoneNumberInputTextField: UITextField = { [weak self] in
        let textField = UITextField.init(frame: CGRect(x: 0, y: (self?.detailLabel.bottom)! + 32, width: __kWidth, height: textFieldHeight))
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: MarginsWidth, height:textFieldHeight))
        
        textField.leftView = view
        textField.leftViewMode = .always
        textField.tintColor = COR1
        textField.font = UIFont.systemFont(ofSize: 21)
        textField.placeholder = LocalizedString(forKey: "密码")
        textField.delegate = self
        textField.layer.borderColor = Gray6Color.cgColor
        textField.layer.borderWidth = 1.0
        textField.isSecureTextEntry = true
//        textField.keyboardType = .default
        return textField
        }()
    
    lazy var confirmButton: UIButton = { [weak self] in
        let button = UIButton.init(frame: CGRect(x: MarginsWidth, y: (self?.phoneNumberInputTextField.bottom)! + 32, width:__kWidth - MarginsWidth*2 , height: 44))
        button.setTitle(LocalizedString(forKey: "确定"), for: UIControlState.normal)
        button.setTitleColor(.white, for: UIControlState.normal)
        button.setTitleColor(COR1, for: UIControlState.disabled)
        button.setBackgroundImage(UIImage.init(color: COR1), for: UIControlState.normal)
        button.setBackgroundImage(UIImage.init(color: Gray12Color), for: UIControlState.disabled)
        button.layer.cornerRadius = 44/2
        button.clipsToBounds = true
        
        button.addTarget(self, action: #selector(confirmButtonTap(_ :)), for: UIControlEvents.touchUpInside)
        return button
        }()
    
}

extension DeviceSambaSetPasswordViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let rawText = textField.text else {
            return true
        }
        
        let fullString = NSString(string: rawText).replacingCharacters(in: range, with: string)
        if fullString.count > 0 && Validate.phoneNum(fullString).isRight{
            //            nextButtonEnableStyle()
        }else{
            //            nextButtonDisableStyle()
        }
        return true
    }
    
}

