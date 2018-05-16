//
//  FilesSearchMoreBottomSheetContentTableViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/16.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

protocol SearchMoreBottomSheetVCDelegate {
    func searchMoreBottomSheettableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
}
class FilesSearchMoreBottomSheetContentTableViewController: UITableViewController {
    var delegate:SearchMoreBottomSheetVCDelegate?
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
        return 3
    }

 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.textColor = DarkGrayColor
        cell.textLabel?.font = MiddleTitleFont
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = LocalizedString(forKey: "Sort by...")
        case 1:
            cell.textLabel?.text = LocalizedString(forKey: "Select...")
        case 2:
            cell.textLabel?.text = LocalizedString(forKey: "Select all")
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let delegateOK = self.delegate {
            delegateOK.searchMoreBottomSheettableView(tableView, didSelectRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
}
