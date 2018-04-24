//
//  IPAddDeviceViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/24.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class IPAddDeviceViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        appBar.headerViewController.headerView.backgroundColor = COR2
        addNavigationItemBar()
    }

    func addNavigationItemBar() {
        let leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "close.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(leftBarButtonItemClick(_ :)))
        appBar.navigationBar.leftBarButtonItem = leftBarButtonItem
        
        let rightBarButtonItem = UIBarButtonItem.init(title: LocalizedString(forKey: "confirm"), style: UIBarButtonItemStyle.plain, target: self, action:#selector(rightBarButtonItemClick(_ :)))
        appBar.navigationBar.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc func leftBarButtonItemClick(_ sender:UIBarButtonItem){
        self.dismiss(animated: true) {
            
        }
    }
    
    @objc func rightBarButtonItemClick(_ sender:UIBarButtonItem){
        
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
