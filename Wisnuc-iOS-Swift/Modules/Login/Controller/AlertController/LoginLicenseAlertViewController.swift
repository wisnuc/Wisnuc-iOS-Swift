//
//  LoginLicenseAlertViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/12/27.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MDCButton

class LoginLicenseAlertViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var confirmButton: MDCFlatButton!
    
    @IBAction func confirmButtonClick(_ sender: MDCFlatButton) {
    self.presentingViewController?.dismiss(animated: true, completion: {
            
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = LocalizedString(forKey: "用户许可使用协议")
        self.confirmButton.setTitle(LocalizedString(forKey: "Confirm"), for: UIControlState.normal)
        self.confirmButton.setTitleColor(COR1, for: UIControlState.normal)
        webView.delegate = self
        let rtfUrl = Bundle.main.path(forResource: "License", ofType: "rtf")
        var request: URLRequest? = nil
        if let url = rtfUrl {
            let path = URL.init(fileURLWithPath: url)
            request = URLRequest(url: path)
            if let aRequest = request {
                webView.loadRequest(aRequest)
            }
        }
        // Do any additional setup after loading the view.
    }
}

extension LoginLicenseAlertViewController:UIWebViewDelegate{
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].style.background='#FFFFFF'")

    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
         webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].style.background='#FFFFFF'")
    }
}
