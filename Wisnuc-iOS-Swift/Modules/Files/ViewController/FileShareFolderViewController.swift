//
//  FileShareFolderViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/14.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialShadowLayer

private let reuseIdentifier = "cellreuseIdentifier"

class FileShareFolderViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appBar.navigationBar.title = LocalizedString(forKey: "files_offline")
        self.appBar.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:DarkGrayColor]
        self.view.addSubview(self.tableView)
    }
    override func viewWillAppear(_ animated: Bool) {
        appBar.headerViewController.headerView.backgroundColor = .white
        appBar.navigationBar.backgroundColor = .white
        appBar.headerStackView.backgroundColor = .white
        let shadowLayer = CALayer.init()
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowOffset = CGSize(width: 2, height: 4)
        shadowLayer.shadowRadius = 2
        appBar.headerViewController.headerView.setShadowLayer(MDCShadowLayer.init(layer: shadowLayer)) { (layer, intensity) in
            let shadowLayer = layer as? MDCShadowLayer
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            shadowLayer!.elevation = ShadowElevation(intensity * ShadowElevation.appBar.rawValue)
            CATransaction.commit()
        }
        appBar.headerViewController.headerView.clipsToBounds  = false
        self.appBar.navigationBar.tintColor = LightGrayColor
        self.appBar.headerViewController.headerView.tintColor = LightGrayColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
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
        tbView.register(UINib.init(nibName: "FilesOfflineTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        return tbView
    }()
    
}

// MARK: - Table view data source
extension FileShareFolderViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:FilesOfflineTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FilesOfflineTableViewCell
        cell.selectionStyle = .none
        cell.leftImageView.image = UIImage.init(named: "files_ppt_small.png")
        cell.titleLabel.text = "这是一个文件名"
        cell.detailLabel.text = "2016.02.02 20.5GB"
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
        return 72
    }
    

}

