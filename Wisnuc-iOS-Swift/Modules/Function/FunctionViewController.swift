//
//  FunctionViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/8/24.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

class FunctionViewController: BaseViewController {
    let id = "Cell"
    override init(style: NavigationStyle) {
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = LocalizedString(forKey: "功能")
        self.functionTableView.register(UITableViewCell.self, forCellReuseIdentifier: id)
        self.view.addSubview(self.functionTableView)
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.trackingScrollView = self.functionTableView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var functionTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight), style: UITableViewStyle.plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        return tableView
    }()
}

extension FunctionViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = LocalizedString(forKey: "共享空间")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            let shareVC = FileShareFolderViewController.init(style:.whiteStyle)
            let tab = retrieveTabbarController()
            tab?.setTabBarHidden(true, animated: true)
            self.navigationController?.pushViewController(shareVC, animated: true)
        default:
            break
        }
    }
}
