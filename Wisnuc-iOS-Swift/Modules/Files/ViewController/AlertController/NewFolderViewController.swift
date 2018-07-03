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
@objc protocol NewFolderViewControllerDelegate {
    func createNewFolderfDidFinish()
}

class NewFolderViewController: UIViewController {
    weak var delegate : NewFolderViewControllerDelegate?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var inputTextField: MDCTextField!
    @IBOutlet weak var creatButton: MDCFlatButton!
    @IBOutlet weak var cancelButton: MDCFlatButton!
    var inputTextFieldController:MDCTextInputControllerUnderline?
    var drive:String?
    var dir:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        creatButton.setTitle(LocalizedString(forKey: "Create"), for: UIControlState.normal)
        creatButton.setTitleColor(COR1, for: UIControlState.normal)
        cancelButton.setTitleColor(COR1, for: UIControlState.normal)
        cancelButton.setTitle(LocalizedString(forKey: "Cancel"), for: UIControlState.normal)
        inputTextField.clearButtonMode = .never
        self.titleLabel.text = LocalizedString(forKey: "New Folder")
        self.inputTextFieldController = MDCTextInputControllerUnderline.init(textInput: inputTextField)
        self.inputTextFieldController?.isFloatingEnabled = false
        self.inputTextFieldController?.placeholderText = LocalizedString(forKey: "Folder Name")
        self.inputTextFieldController?.activeColor = COR1
        inputTextField.text = LocalizedString(forKey: "Untitled folder")
        
    }
    
    func normalStateRequest(){
        MkdirAPI.init(driveUUID: (self.drive!), directoryUUID: (self.dir!), name: (self.inputTextField.text!)).startRequestJSONCompletionHandler { (response) in
            if response.error == nil{
                Message.message(text: LocalizedString(forKey: "Folder created"))
                if let delegateOK = self.delegate {
                    delegateOK.createNewFolderfDidFinish()
                }
            }else{
                if response.data != nil {
                    let errorDict =  dataToNSDictionary(data: response.data!)
                    if errorDict != nil{
                        Message.message(text: errorDict!["message"] != nil ? errorDict!["message"] as! String :  (response.error?.localizedDescription)!)
                    }else{
                        let backToString = String(data: response.data!, encoding: String.Encoding.utf8) as String?
                        Message.message(text: backToString ?? "error")
                    }
                }else{
                    Message.message(text: (response.error?.localizedDescription)!)
                }
            }
        }
    }
    
    func localNetStateRequest() {
        MkdirAPI.init(driveUUID: (self.drive!), directoryUUID: (self.dir!), name: (self.inputTextField.text!)).startFormDataRequestJSONCompletionHandler(multipartFormData: { (formData) in
            let dic = [kRequestOpKey: kRequestMkdirValue]
            do {
                let data = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
                mainThreadSafe {
                    formData.append(data, withName: self.inputTextField.text!)
                }
            }catch{
                Message.message(text: LocalizedString(forKey: ErrorLocalizedDescription.JsonModel.SwitchTODataFail))
            }
        }, { (response) in
            if response.error == nil{
                Message.message(text: LocalizedString(forKey: "Folder created"))
                if let delegateOK = self.delegate {
                    delegateOK.createNewFolderfDidFinish()
                }
            }else{
                if response.data != nil {
                    let errorDict =  dataToNSDictionary(data: response.data!)
                    if errorDict != nil{
                        Message.message(text: errorDict!["message"] != nil ? errorDict!["message"] as! String :  (response.error?.localizedDescription)!)
                    }else{
                        let backToString = String(data: response.data!, encoding: String.Encoding.utf8) as String?
                        Message.message(text: backToString ?? "error")
                    }
                }else{
                    Message.message(text: (response.error?.localizedDescription)!)
                }
            }
        }, errorHandler: { (error) -> (Void) in
            Message.message(text: error.localizedDescription)
        })
    }
    
    @IBAction func createButtonTap(_ sender: MDCFlatButton) {
        self.presentingViewController?.dismiss(animated: true, completion: { [weak self] in
            if self?.inputTextField.text == nil ||  self?.inputTextField.text?.count == 0{
                return
            }
            switch AppNetworkService.networkState {
            case .local?:
                self?.localNetStateRequest()
            case .normal?:
                self?.normalStateRequest()
            default:
                break
            }
 
        })
    }
    
    @IBAction func cancelButtonTap(_ sender: MDCFlatButton) {
        self.presentingViewController?.dismiss(animated: true, completion: {
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
