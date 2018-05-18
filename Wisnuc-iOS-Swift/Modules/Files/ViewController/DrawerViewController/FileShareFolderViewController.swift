//
//  FileShareFolderViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/14.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Material

private let reuseIdentifier = "cellreuseIdentifier"

class FileShareFolderViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appBar.navigationBar.title = LocalizedString(forKey: "files_offline")
        self.view.addSubview(self.tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.appBar.headerViewController.headerView.isHidden = false
        self.navigationItem.rightBarButtonItem = searchBarButtonItem
        Application.statusBarStyle = .default
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    @objc func searchBarButtonItemTap(_ sender:UIBarButtonItem){
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var tableView: UITableView = {
        let tbView = UITableView.init(frame: CGRect(x: 0, y: MDCAppNavigationBarHeight, width: __kWidth, height: __kHeight - MDCAppNavigationBarHeight))
        tbView.delegate = self
        tbView.dataSource = self
        tbView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        tbView.tableFooterView = UIView.init(frame: CGRect.zero)
        tbView.register(UINib.init(nibName: "FilesShareFolderTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        tbView.separatorStyle = .none
        return tbView
    }()
    
    lazy var searchBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem.init(image: Icon.search?.byTintColor(LightGrayColor), style: UIBarButtonItemStyle.done, target: self, action: #selector(searchBarButtonItemTap(_ :)))
        return barButtonItem
    }()
    
    lazy var moreButtonBottomSheetContentVC:FilesShareBottomSheetContentTableViewController = {
        let vc = FilesShareBottomSheetContentTableViewController(style: UITableViewStyle.plain)
        vc.delegate = self
        return vc
    }()
}

// MARK: - Table view data source
extension FileShareFolderViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:FilesShareFolderTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FilesShareFolderTableViewCell
        cell.selectionStyle = .none
        cell.leftImageView.image = UIImage.init(named: "files_share_all.png")
        cell.titleLabel.text = "共享文件夹"
        cell.cellCallback = { (callbackCell,moreButton) in
            let bottomSheet = AppBottomSheetController.init(contentViewController: self.moreButtonBottomSheetContentVC)
           self.present(bottomSheet, animated: true, completion: nil)
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
}

extension FileShareFolderViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}

extension FileShareFolderViewController:ShareBottomSheetContentVCDelegte{
    func shareBottomSheetContenttableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.moreButtonBottomSheetContentVC.presentingViewController?.dismiss(animated: true, completion: {
            let authorityVC = FilesShareAuthorityChangeViewController.init(style: NavigationStyle.defaultStyle)
            self.present(authorityVC, animated: true, completion: nil)
        })
    }
    
 
}

