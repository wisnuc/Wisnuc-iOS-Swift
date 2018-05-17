//
//  TransferTaskTableViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/11.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialShadowLayer
import Material
private let reuseIdentifier = "cellreuseIdentifier"

class TransferTaskTableViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.appBar.navigationBar.title = LocalizedString(forKey: "transfer")
        self.view.addSubview(self.tableView)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.appBar.headerViewController.headerView.isHidden = false
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        if (self.navigationDrawerController?.rootViewController) != nil {
//            let tab = self.navigationDrawerController?.rootViewController as! WSTabBarController
//            tab.setTabBarHidden(false, animated: true)
//        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func rightBarButtonItem(_ sender:UIBarButtonItem){
       let bottomSheet = AppBottomSheetController.init(contentViewController: transferTaskBottomSheetContentVC)
        self.present(bottomSheet, animated: true, completion: nil)
    }

    lazy var tableView: UITableView = {
        let tbView = UITableView.init(frame: CGRect(x: 0, y: MDCAppNavigationBarHeight, width: __kWidth, height: __kHeight - MDCAppNavigationBarHeight))
        tbView.delegate = self
        tbView.dataSource = self
        tbView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        tbView.tableFooterView = UIView.init(frame: CGRect.zero)
        tbView.register(UINib.init(nibName: "TransferTaskTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        return tbView
    }()
    
    lazy var rightBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem.init(image:Icon.moreHorizontal?.byTintColor(LightGrayColor) , style: UIBarButtonItemStyle.done, target: self, action: #selector(rightBarButtonItem(_ :)))
        return barButtonItem
    }()
    
    lazy var transferTaskBottomSheetContentVC: TransferTaskBottomSheetContentTableViewController = {
        let vc = TransferTaskBottomSheetContentTableViewController.init(style: UITableViewStyle.plain)
        vc.delegate = self
        return vc
    }()
    
//    lazy var finishImageView: UIImageView = {
//
//        return imageView
//    }()
}

 // MARK: - Table view data source
extension TransferTaskTableViewController:UITableViewDataSource{
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell:TransferTaskTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TransferTaskTableViewCell
    cell.selectionStyle = .none
    cell.leftImageView.image = UIImage.init(named: "files_pdf.png")
    cell.detailImageView.image = UIImage.init(named: "files_cloud.png")
    cell.titleLabel.text = "这是一个文件名"
    cell.detailLabel.text = "20.5GB"
    let imageViewWidth:CGFloat = 24
    let imageView = UIImageView.init(frame: CGRect(x:cell.width - 16 - imageViewWidth, y: cell.height/2 - imageViewWidth/2, width: imageViewWidth, height: imageViewWidth))
    imageView.image = UIImage.init(named: "files_error.png")
    cell.contentView.addSubview(imageView)
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

extension TransferTaskTableViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.default, title: LocalizedString(forKey: "delete")) { (tableViewForAction, indexForAction) in
        
        }
        deleteRowAction.backgroundColor = UIColor.red
        let priorityRowAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.default, title: LocalizedString(forKey: "priority_transfer")) { (tableViewForAction, indexForAction) in
            
        }
        priorityRowAction.backgroundColor = UIColor.purple
        return [deleteRowAction,priorityRowAction]
    }
}

extension TransferTaskTableViewController:TransferTaskBottomSheetContentVCDelegate{
    func transferTaskBottomSheettableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.transferTaskBottomSheetContentVC.presentingViewController?.dismiss(animated: true, completion: {
            
        })
    }
}
