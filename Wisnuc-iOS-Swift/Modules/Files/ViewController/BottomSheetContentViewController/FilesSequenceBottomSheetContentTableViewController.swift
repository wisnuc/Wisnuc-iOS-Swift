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

@objc protocol SequenceBottomSheetContentVCDelegate {
    func sequenceBottomtableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath,isDown:Bool)
}

class FilesSequenceBottomSheetContentTableViewController: UITableViewController {
    deinit {
        print("\(className()) deinit")
    }
    weak var delegate:SequenceBottomSheetContentVCDelegate?
    var lastPath:IndexPath?
    var isDown:Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        if AppUserService.currentUser?.sortType != nil {
            lastPath = IndexPath.init(row: (AppUserService.currentUser?.sortType?.intValue)!, section: 0)
        }else{
            lastPath = IndexPath.init(row: 0, section: 0)
        }
        
        if AppUserService.currentUser?.sortIsDown != nil {
            isDown = AppUserService.currentUser?.sortIsDown!.boolValue
        }else{
            isDown = true
        }

        self.tableView.register(UINib.init(nibName: "FilesSequenceTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
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
        cell.leftImageView.isHidden = true
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = LocalizedString(forKey: "按名称的正序与倒序")
            if isDown == nil{
                cell.leftImageView.isHidden = false
            }
        case 1:
            cell.titleLabel.text = LocalizedString(forKey: "按修改日期的正序与倒序")

        case 2:
            cell.titleLabel.text = LocalizedString(forKey: "按创建日期的的正序与倒序")

        case 3:
            cell.titleLabel.text = LocalizedString(forKey: "按容量大小的正序与倒序")
        default:
            break
        }
        
        let row = indexPath.row
        
        let oldRow = lastPath?.row
        
        if (row == oldRow && lastPath != nil) {
            
            //这个是系统中对勾的那种选择框
            
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            cell.leftImageView.isHidden = false
            
        }else{
            cell.accessoryType = UITableViewCellAccessoryType.none
            cell.leftImageView.isHidden = true
        }
        
        if isDown != nil &&  isDown!{
            cell.leftImageView.image = UIImage.init(named: "files_arrow_down.png")
        }else{
            cell.leftImageView.image = UIImage.init(named: "files_arrow_up.png")
        
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newRow = indexPath.row
        let oldRow = self.lastPath != nil ? self.lastPath?.row:-1
        if (newRow != oldRow) {
            let newCell = tableView.cellForRow(at: indexPath)
            newCell?.accessoryType = UITableViewCellAccessoryType.checkmark
            let oldCell = tableView.cellForRow(at: self.lastPath!)
            oldCell?.accessoryType = UITableViewCellAccessoryType.none
            self .lastPath = indexPath;
            isDown = true
        }else{
            isDown = !isDown!
        }
        tableView.deselectRow(at: indexPath, animated: true)
            let cell = tableView.cellForRow(at: indexPath) as! FilesSequenceTableViewCell
            UIView.animate(withDuration: TimeInterval.init(1), animations:{  [weak self] in
//               backgroundColor = UIColor.green
                UIView.performWithoutAnimation {
                    if self?.isDown != nil &&  (self?.isDown!)!{
                        cell.leftImageView.image = UIImage.init(named: "files_arrow_down.png")
                    }else{
                        cell.leftImageView.image = UIImage.init(named: "files_arrow_up.png")
                    }
                    cell.leftImageView.isHidden = false
                }
            })
        
            let yourDelay = 100
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(yourDelay), execute: { [weak self] () -> Void in
                self?.dismiss(animated: true) {
                    if let delegateOK = self?.delegate{
                        delegateOK.sequenceBottomtableView(tableView, didSelectRowAt: indexPath, isDown: (self?.isDown!)!)
                    }
                }
            })
                
            self.tableView.reloadData()
    }
}
