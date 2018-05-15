//
//  FilesSequenceBottomSheetContentTableViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/15.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

private let reuseIdentifier = "reuseIdentifier"
private let cellHeight:CGFloat = 48.0

protocol SequenceBottomSheetContentVCDelegate {
    func sequenceBottomtableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
}

class FilesSequenceBottomSheetContentTableViewController: UITableViewController {
    var delegate:SequenceBottomSheetContentVCDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib.init(nibName: "FilesSequenceTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView.init(frame: CGRect.zero)
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
        let cell:FilesSequenceTableViewCell = tableView.dequeueReusableCell(withIdentifier:reuseIdentifier , for: indexPath) as! FilesSequenceTableViewCell
        cell.tintColor = COR1
        cell.selectionStyle = .none
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = LocalizedString(forKey: "按名称的正序与倒序")
            cell.leftImageView.isHidden = false
            
        case 1:
            cell.titleLabel.text = LocalizedString(forKey: "按修改日期的正序与倒序")
            cell.leftImageView.isHidden = true
        case 2:
            cell.titleLabel.text = LocalizedString(forKey: "按创建日期的的正序与倒序")
            cell.leftImageView.isHidden = true
        case 3:
            cell.titleLabel.text = LocalizedString(forKey: "按容量大小的正序与倒序")
            cell.leftImageView.isHidden = true
        default:
            break
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newCell = tableView.cellForRow(at: indexPath)

        if newCell?.accessoryType == UITableViewCellAccessoryType.none
        {

            newCell?.accessoryType = UITableViewCellAccessoryType.checkmark

        }
        self.dismiss(animated: true) {
            if let delegateOK = self.delegate{
                delegateOK.sequenceBottomtableView(tableView, didSelectRowAt: indexPath)
            }
        }
    }

}
