//
//  NewAlbumMoreBottomSheetTableViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/31.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

@objc protocol NewAlbumMoreBottomSheetTableViewControllerDelegate {
    func newAlbumMoreBottomSheetTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
}
class NewAlbumMoreBottomSheetTableViewController: UITableViewController {
    weak var delegate:NewAlbumMoreBottomSheetTableViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .none
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.textColor = DarkGrayColor
        cell.textLabel?.font = MiddleTitleFont
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = LocalizedString(forKey: "选择")
        case 1:
            cell.textLabel?.text = LocalizedString(forKey: "编辑相册")
        case 2:
            cell.textLabel?.text = LocalizedString(forKey: "更改相册封面")
        case 3:
            cell.textLabel?.text = LocalizedString(forKey: "删除相册")
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.presentingViewController?.dismiss(animated: true) { [weak self] in
            if let delegateOK = self?.delegate {
                delegateOK.newAlbumMoreBottomSheetTableView(tableView, didSelectRowAt: indexPath)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
}

