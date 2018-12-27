//
//  MyUserAgreementViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/15.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class MyUserAgreementViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = LocalizedString(forKey: "用户许可使用协议")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "close_white.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(dismiss(_ :)))
        self.view.addSubview(webview)
        let rtfUrl = Bundle.main.path(forResource: "License", ofType: "rtf")
        var request: URLRequest? = nil
        if let url = rtfUrl {
            let path = URL.init(fileURLWithPath: url)
            request = URLRequest(url: path)
            if let aRequest = request {
                webview.loadRequest(aRequest)
            }
        }
        // Do any additional setup after loading the view.
    }
    
    @objc func dismiss(_ sender:UIBarButtonItem){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    lazy var webview: UIWebView = {
        let view = UIWebView.init(frame: CGRect(x: 0, y: appBar.headerViewController.headerView.height, width: __kWidth, height: __kHeight - appBar.headerViewController.headerView.height))
        return view
    }()
}
