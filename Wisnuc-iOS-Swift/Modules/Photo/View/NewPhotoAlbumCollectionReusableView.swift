//
//  NewPhotoAlbumCollectionReusableView.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/25.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTextFields
import Material

private let textFieldTopMargin:CGFloat = 36
private let textFieldLeftMargin:CGFloat = 66
enum NewPhotoAlbumCollectionReusableViewState{
    case normal
    case editing
}

class NewPhotoAlbumCollectionReusableView: UICollectionReusableView {
    var headerExtensionArray:Array<HeaderExtensionType>?{
        didSet{
            if (headerExtensionArray?.contains(.textView))!{
                self.addSubview(textView)
            }
        }
    }
    var stateChangeClosure:((_ state:NewPhotoAlbumCollectionReusableViewState)->())?
    var state:NewPhotoAlbumCollectionReusableViewState?{
        didSet{
            switch state {
            case .normal?:
                 setTextFieldNormal()
            case .editing?:
                setEditingState()
            default:
                break
            }
        }
    }
    
    lazy var textField = MDCTextField.init(frame: CGRect.init(x: textFieldTopMargin, y: textFieldLeftMargin, width: self.width - textFieldLeftMargin - MarginsWidth, height: 88))
    lazy var textView:UITextView = UITextView.init(frame: CGRect(x: MarginsWidth, y: self.textField.bottom + MarginsWidth, width: self.width - MarginsWidth*2, height: 88), textContainer: nil)
    var inputTextFieldController:MDCTextInputControllerUnderline?
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
//        self.inputTextFieldController = MDCTextInputControllerUnderline.init(textInput: textField)
//        self.inputTextFieldController?.helperText = TimeTools.getCurrentDay()
   
        textView.delegate = self
        textField.delegate = self
        self.addSubview(textField)
        textField.becomeFirstResponder()
    }
    
    func setNormalState(){
        setTextFieldNormal()
    }
    
    func setEditingState(){
        setTextFieldEditing()
    }
    
    func setTextFieldNormal(){
        textField.textColor = DarkGrayColor
        textField.font = UIFont.systemFont(ofSize: 34)
        if #available(iOS 10.0, *) {
            textField.adjustsFontForContentSizeCategory = true
        } else {
            textField.mdc_adjustsFontForContentSizeCategory = true
        }
         self.inputTextFieldController  = nil
        self.inputTextFieldController = MDCTextInputControllerUnderline.init(textInput: textField)
        self.inputTextFieldController?.helperText = TimeTools.getCurrentDay()
        self.inputTextFieldController?.isFloatingEnabled = false
        self.inputTextFieldController?.normalColor = .white
        self.inputTextFieldController?.disabledColor = .white
        self.inputTextFieldController?.underlineViewMode = .never
        self.inputTextFieldController?.placeholderText = "相簿标题"
        self.inputTextFieldController?.activeColor = COR3
        self.endEditing(true)
        
        textView.clipsToBounds = true
    }
    
    
    func setTextFieldEditing(){
        textField.textColor = DarkGrayColor
        textField.isEnabled = true
        textField.font = UIFont.systemFont(ofSize: 34)
        if #available(iOS 10.0, *) {
            textField.adjustsFontForContentSizeCategory = true
        } else {
            textField.mdc_adjustsFontForContentSizeCategory = true
        }
    
        textField.clearButtonMode = .whileEditing
         self.inputTextFieldController  = nil
        self.inputTextFieldController = MDCTextInputControllerUnderline.init(textInput: textField)
        self.inputTextFieldController?.helperText = TimeTools.getCurrentDay()
        self.inputTextFieldController?.isFloatingEnabled = false
        self.inputTextFieldController?.placeholderText = "相簿标题"
        self.inputTextFieldController?.activeColor = COR3
        textView.clipsToBounds = false
        textView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        textView.layer.shadowRadius = 1
        textView.layer.shadowOpacity = 0.5
        textView.layer.shadowColor = DarkGrayColor.cgColor
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 2
        textView.clipsToBounds = false
        textView.textColor = LightGrayColor
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.tintColor = COR3
//        self.inputTextFieldController?.underlineViewMode = .whileEditing
    }
}

extension NewPhotoAlbumCollectionReusableView:UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        if isNilString(textField.text){
            textField.text = LocalizedString(forKey: "未命名相册")
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.state = .editing
        if stateChangeClosure != nil{
            self.stateChangeClosure!(self.state ?? .normal)
        }
    }
}

extension NewPhotoAlbumCollectionReusableView:UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.state = .editing
        if stateChangeClosure != nil{
            self.stateChangeClosure!(self.state ?? .normal)
        }
    }
}

