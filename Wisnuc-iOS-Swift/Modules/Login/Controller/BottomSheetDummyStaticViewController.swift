//
//  BottomSheetDummyStaticViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/19.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class BottomSheetDummyStaticViewController: UIViewController {
    var overflowView:UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red
        // Do any additional setup after loading the view.
        overflowView = UIView.init(frame: CGRect.zero)
        overflowView?.backgroundColor = self.view.backgroundColor
        self.view.addSubview(overflowView!)
    }
    

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let size = self.view.frame.size
        overflowView?.frame = CGRect(x: 0, y: size.height, width: size.width, height: 200)
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
