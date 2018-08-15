//
//  NewFolderViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/3.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialTextFields
import IQKeyboardManagerSwift

@objc enum InputAlertType:Int {
    case creatNewFolder
    case rename
}

@objc protocol NewFolderViewControllerDelegate {
    func confirmButtonTap(_ sender: MDCFlatButton,type:InputAlertType ,inputText:String,theFilesName:String?)
}

class NewFolderViewController: UIViewController {
    override func willDealloc() -> Bool {
        return false
    }
    weak var delegate : NewFolderViewControllerDelegate?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputTextField: MDCTextField!
    @IBOutlet weak var confirmButton: MDCFlatButton!
    @IBOutlet weak var cancelButton: MDCFlatButton!
    var theFilesName:String?
    var type:InputAlertType?
    var titleString:String?
    var inputPlaceholder:String?
    var inputString:String?
    var confirmButtonName:String?
    var themeColor:UIColor?
    var inputTextFieldController:MDCTextInputControllerUnderline?
    override func viewDidLoad() {
        super.viewDidLoad()
        confirmButton.setTitle(confirmButtonName!, for: UIControlState.normal)
        confirmButton.setTitleColor(themeColor ?? COR1, for: UIControlState.normal)
        cancelButton.setTitleColor(themeColor ?? COR1, for: UIControlState.normal)
        cancelButton.setTitle(LocalizedString(forKey: "Cancel"), for: UIControlState.normal)
        inputTextField.clearButtonMode = .never
        self.titleLabel.text = titleString!
        self.inputTextFieldController = MDCTextInputControllerUnderline.init(textInput: inputTextField)
        self.inputTextFieldController?.isFloatingEnabled = false
        self.inputTextFieldController?.placeholderText = inputPlaceholder!
        self.inputTextFieldController?.activeColor = COR1
        inputTextField.text =  inputString!
    }
    
    deinit {
        print("newFolder VC deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let keyboardManager =  IQKeyboardManager.shared
        keyboardManager.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let keyboardManager =  IQKeyboardManager.shared
        keyboardManager.enable = true
    }
    
    @IBAction func confirmButtonButtonTap(_ sender: MDCFlatButton) {
        self.presentingViewController?.dismiss(animated: true, completion: { [weak self] in
            if self?.inputTextField.text == nil ||  self?.inputTextField.text?.count == 0{
                return
            }
            
            if let delegateOK = self?.delegate {
                delegateOK.confirmButtonTap(sender, type: (self?.type!)!, inputText: (self?.inputTextField.text!)!, theFilesName: self?.theFilesName)
            }
        })
    }
    
    @IBAction func cancelButtonTap(_ sender: MDCFlatButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
