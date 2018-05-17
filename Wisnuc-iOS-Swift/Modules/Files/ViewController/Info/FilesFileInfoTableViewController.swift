//
//  FilesFileInfoTableViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/16.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MDCAppBar
private let cellReuseIdentifier = "reuseIdentifier"
class FilesFileInfoTableViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.isHidden = false
        let tab = self.navigationDrawerController?.rootViewController as! WSTabBarController
        tab.setTabBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func prepareNavigationBar(){
        appBar.headerViewController.headerView.trackingScrollView = self.tableView
        self.tableView.delegate = appBar.headerViewController
        self.view.addSubview(tableView)
        ViewTools.automaticallyAdjustsScrollView(scrollView: tableView, viewController: self)
        view.bringSubview(toFront: appBar.headerViewController.headerView)
        appBar.navigationBar.title = "fom.pdf"
        appBar.navigationBar.titleTextColor = .clear
        appBar.headerViewController.headerView.addSubview(navigationBarBottomImageView)
        appBar.headerViewController.headerView.addSubview(navigationBarBottomLabel)
        appBar.headerViewController.headerView.delegate = self
        navigationBarBottomImageView.image = UIImage.init(named: "files_files.png")
        navigationBarBottomLabel.text = appBar.navigationBar.title
    }

    lazy var tableView: UITableView = {
        let contentTableView = UITableView.init(frame: CGRect.init(x: 0, y: 0, width: __kWidth, height: __kHeight), style:.plain)
        contentTableView.delegate = self
        contentTableView.dataSource = self
        contentTableView.register(UINib.init(nibName:StringExtension.classNameAsString(obj: FilesFileInfoTableViewCell()), bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        contentTableView.separatorStyle = .none
        contentTableView.contentInset = UIEdgeInsets.init(top:MarginsCloseWidth, left: 0, bottom: 0, right: 0)
        return contentTableView
    }()
    
    lazy var navigationBarBottomImageView: UIImageView = {
        let imageView = UIImageView.init(frame: CGRect.init(x: MarginsWidth, y: appBar.headerViewController.headerView.maximumHeight - MarginsWidth - 24, width: 24, height: 24))
        return imageView
    }()
    
    lazy var navigationBarBottomLabel: UILabel = {
        let label = UILabel.init(frame: CGRect.init(x:navigationBarBottomImageView.right + MarginsWidth, y: appBar.headerViewController.headerView.maximumHeight - MarginsWidth -  24, width: __kWidth - navigationBarBottomImageView.right - MarginsWidth*2, height: 24))
        label.textColor = DarkGrayColor
        label.font = MiddlePlusTitleFont.withBold()
        label.text = appBar.navigationBar.title!
        return label
    }()
}

extension FilesFileInfoTableViewController:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - Table view data source
extension FilesFileInfoTableViewController:UITableViewDataSource{
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:FilesFileInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! FilesFileInfoTableViewCell
        cell.selectionStyle = .none
        switch indexPath.row {
        case 0:
            cell.leftLabel.text = LocalizedString(forKey: "Type")
            cell.rightLabel.text = "Microsoft Powerpoint"
        case 1:
            cell.leftLabel.text = LocalizedString(forKey: "Size")
            cell.rightLabel.text = "1MB"
        case 2:
            cell.leftLabel.text = LocalizedString(forKey: "Position")
            cell.rightLabel.isHidden = true
            cell.filesImageView.isHidden = false
            cell.folderButton.isHidden = false
            cell.folderButton.setTitle("My Drive", for: UIControlState.normal)
        case 3:
            cell.leftLabel.text = LocalizedString(forKey: "Files quantity")
            cell.rightLabel.text = "10"
        case 4:
            cell.leftLabel.text = LocalizedString(forKey: "Media files quantity")
            cell.rightLabel.text = "2"
        case 5:
            cell.leftLabel.text = LocalizedString(forKey: "Creat Time")
            cell.rightLabel.text = "30/12/2016 by Leo An"
        case 6:
            cell.leftLabel.text = LocalizedString(forKey: "Modify")
            cell.rightLabel.text = "30/12/2016 by Leo An"
        default:
            break
        }
        return cell
    }

}

extension FilesFileInfoTableViewController:MDCFlexibleHeaderViewDelegate{
    func flexibleHeaderViewNeedsStatusBarAppearanceUpdate(_ headerView: MDCFlexibleHeaderView) {
        
    }
    
    func flexibleHeaderViewFrameDidChange(_ headerView: MDCFlexibleHeaderView) {
//       print(headerView.bottom)
        let viewOriginY:CGFloat = 120.0
        if headerView.maximumHeight != headerView.bottom{
             navigationBarBottomImageView.origin.y = viewOriginY + headerView.bottom - headerView.maximumHeight
            navigationBarBottomImageView.alpha = (navigationBarBottomImageView.origin.y-64)/(120-64)
            navigationBarBottomLabel.origin.y = viewOriginY + headerView.bottom - headerView.maximumHeight
        }
    }
}
