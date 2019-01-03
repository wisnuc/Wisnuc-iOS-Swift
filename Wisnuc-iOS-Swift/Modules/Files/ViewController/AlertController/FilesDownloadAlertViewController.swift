//
//  FilesDownloadAlertViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/8/14.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons
@objc protocol  FilesDownloadAlertViewControllerDelegate{
    func cancelButtonTap()
}

//下载提示弹窗
class FilesDownloadAlertViewController: UIViewController {
    weak var delegate:FilesDownloadAlertViewControllerDelegate?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var downloadProgressView: UIProgressView!
    @IBOutlet weak var cancelButton: MDCFlatButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = LocalizedString(forKey: "正在加载")
        cancelButton.setTitle(LocalizedString(forKey: "Cancel"), for: UIControlState.normal)
        cancelButton.setTitleColor(COR1, for: UIControlState.normal)
        downloadProgressView.progressTintColor = COR1
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonTap(_ sender: MDCFlatButton) {
        if let delegateOK = delegate{
            self.presentingViewController?.dismiss(animated: true) { [weak delegateOK] in
                delegateOK?.cancelButtonTap()
            }
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
