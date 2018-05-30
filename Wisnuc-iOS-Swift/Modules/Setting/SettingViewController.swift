//
//  SettingViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/30.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

private let identifier = "celled"

class SettingViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        appBar.headerViewController.headerView.trackingScrollView = settingTabelView
        self.view.addSubview(settingTabelView)
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        
    }
    
    func logoutAction(){
        AppUserService.logoutUser()
        AppService.sharedInstance().abort()
        appDelegate.initRootVC()
//        appDelegate.setR
    }
    
    lazy var settingTabelView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
        return tableView
    }()
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension SettingViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.logoutAction()
    }
}

extension SettingViewController:UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.textLabel?.text = LocalizedString(forKey: "Log out")
        return cell
    }

}
