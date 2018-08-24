//
//  FilesShareAuthorityChangeViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/18.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import Material
private let Identifier = "Celled"

class FilesShareAuthorityChangeViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareForNavigationBar()
        self.view.addSubview(mainTableView)
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
        appBar.navigationBar.addSubview(textField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        appBar.headerViewController.headerView.trackingScrollView = self.mainTableView
        mainTableView.contentInset = UIEdgeInsetsMake(mainTableView.contentInset.top + 8, 0, 0, 0)
    }
    
    @objc func closeBarButtonItemTap(_ sender:UIBarButtonItem){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func rightBarButtonItemTap(_ sender:UIBarButtonItem){
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    func prepareForNavigationBar() {
        let leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "close_white.png"), style: UIBarButtonItemStyle.done, target: self, action: #selector(closeBarButtonItemTap(_ :)))
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        
        let rightBarButtonItem = UIBarButtonItem.init(title: LocalizedString(forKey: "Confirm"), style: UIBarButtonItemStyle.done, target: self, action: #selector(rightBarButtonItemTap(_ :)))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
    }

    lazy var mainTableView: UITableView = {
        let contentTableView = UITableView.init(frame: CGRect(x: 0, y: 0, width: __kWidth, height: __kHeight), style: UITableViewStyle.plain)
        contentTableView.delegate = self
        contentTableView.dataSource = self as UITableViewDataSource
        contentTableView.register(UINib.init(nibName: StringExtension.classNameAsString(targetClass: FilesAShareAuthorityTableViewCell.self), bundle: nil), forCellReuseIdentifier: Identifier)
        contentTableView.separatorStyle = .none
        contentTableView.tableFooterView = UIView.init(frame: CGRect.zero)
        return contentTableView
    }()
    
    lazy var textField: TextField = {
        let left = MarginsWidth + MarginsSoFarWidth + MarginsWidth*2
        let contentTextField = TextField.init(frame: CGRect(x: left, y: 0, width: __kWidth - left - MarginsWidth - 28 - 28, height: 44))
        contentTextField.dividerActiveColor = LightGrayColor
        return contentTextField
    }()
}

extension FilesShareAuthorityChangeViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:FilesAShareAuthorityTableViewCell = tableView.dequeueReusableCell(withIdentifier: Identifier, for: indexPath) as! FilesAShareAuthorityTableViewCell
        cell.titleLable.text = "Mark"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}
