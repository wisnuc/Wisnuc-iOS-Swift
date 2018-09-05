//
//  FilesFABBottomSheetDisplayViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/15.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit


@objc protocol  FABBottomSheetDisplayVCDelegte{
    func cllButtonTap(_ sender: UIButton)
    func folderButtonTap(_ sender: UIButton)
    func uploadButtonTap(_ sender: UIButton)
}
class FilesFABBottomSheetDisplayViewController: UIViewController {
//    override func willDealloc() -> Bool {
//        return false
//    }
    weak var delegate:FABBottomSheetDisplayVCDelegte?
    @IBOutlet weak var folderButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var cllButton: UIButton!
    @IBOutlet weak var bottomSheetTitleLabel: UILabel!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var cllLabel: UILabel!
    @IBOutlet weak var folderLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomSheetTitleLabel.font = MiddleTitleFont
        bottomSheetTitleLabel.textColor = DarkGrayColor
        bottomSheetTitleLabel.text = LocalizedString(forKey: "New")
        
        folderLabel.textAlignment = .center
        folderLabel.textColor = LightGrayColor
        folderLabel.font = SmallTitleFont
        folderLabel.text = LocalizedString(forKey: "folder")
        
        uploadLabel.textAlignment = .center
        uploadLabel.textColor = LightGrayColor
        uploadLabel.font = SmallTitleFont
        uploadLabel.text = LocalizedString(forKey: "upload")
        
        cllLabel.textAlignment = .center
        cllLabel.textColor = LightGrayColor
        cllLabel.font = SmallTitleFont
        cllLabel.text = LocalizedString(forKey: "magnet")
    }

    @IBAction func cllButtonTap(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: {
            if let delegateOK = self.delegate {
                delegateOK.cllButtonTap(sender)
            }
        })
    }
    
    @IBAction func folderButtonTap(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: {
            if let delegateOK = self.delegate {
                delegateOK.folderButtonTap(sender)
            }
        })
    }
    
    @IBAction func uploadButtonTap(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: {
            if let delegateOK = self.delegate {
                delegateOK.uploadButtonTap(sender)
            }
        })
    }
    
    deinit {
        print("fabBottom deinit")
    }
}
