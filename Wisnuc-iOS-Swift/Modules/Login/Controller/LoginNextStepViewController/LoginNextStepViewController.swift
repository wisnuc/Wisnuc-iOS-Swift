//
//  LoginNextStepViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/8/28.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class LoginNextStepViewController: BaseViewController {
    var titleString:String?
    var detailTitleString:String?
    var textFiledTitleString:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x: <#T##CGFloat#>, y: <#T##CGFloat#>, width: <#T##CGFloat#>, height: <#T##CGFloat#>))
        return <#value#>
    }()
    
    
}
