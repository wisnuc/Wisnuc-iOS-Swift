//
//  LocalNetworkLoginViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/18.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class LocalNetworkLoginViewController: BaseViewController {

    @IBOutlet weak var mainbackgroudView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizedString(forKey: "局域网设备")
        mainbackgroudView.backgroundColor = SkyBlueColor
        appBar.navigationBar.backgroundColor = SkyBlueColor
        appBar.headerViewController.headerView.backgroundColor = SkyBlueColor
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
