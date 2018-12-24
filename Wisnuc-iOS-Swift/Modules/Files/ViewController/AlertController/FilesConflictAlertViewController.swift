//
//  FilesConflictAlertViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/12/24.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

@objc protocol FilesConflictAlertViewControllerDelegate {
    func conflictAction(action:String)
}

class FilesConflictAlertViewController: UIViewController {
    weak var delegate:FilesConflictAlertViewControllerDelegate?
    let identifier = "celled"
    let cellHeight:CGFloat = 54
    @IBOutlet weak var actionSelectTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var cancelButton: MDCFlatButton!
    @IBOutlet weak var confirmButton: MDCFlatButton!
    let actions = [FilesTaskPolicy.rename, FilesTaskPolicy.replace, FilesTaskPolicy.skip]
    var model:FilesTasksModel?
    var selectType:String?
    var confirmCallback:((_ selectType:String)->())?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = LocalizedString(forKey: "命名冲突")
        let name = model?.nodes?.first?.src?.name
        self.detailLabel.textColor = LightGrayColor
        self.detailLabel.text = LocalizedString(forKey: "\(name ?? "")已存在，请选择您要执行的操作")
        self.detailLabel.numberOfLines = 0
        self.cancelButton.setTitle(LocalizedString(forKey: "Cancel"), for: UIControlState.normal)
        self.cancelButton.setTitleColor(COR1, for: UIControlState.normal)
        self.confirmButton.setTitle(LocalizedString(forKey: "Confirm"), for: UIControlState.normal)
        self.confirmButton.setTitleColor(COR1, for: UIControlState.normal)
        actionSelectTableView.dataSource = self
        actionSelectTableView.delegate = self
        actionSelectTableView.register(UINib.init(nibName: StringExtension.classNameAsString(targetClass: DeviceAddDeviceTableViewCell.self), bundle: nil), forCellReuseIdentifier: identifier)
        actionSelectTableView.tableFooterView = UIView.init(frame: CGRect.zero)
    
    }
    @IBAction func confirmButtonClick(_ sender: MDCFlatButton) {
        if let type = self.selectType{
            delegate?.conflictAction(action:type)
            if let callback = self.confirmCallback{
                callback(type)
            }
        }
       
        self.presentingViewController?.dismiss(animated: true, completion: {
            
        })
    }
    @IBAction func cancelButtonClick(_ sender: MDCFlatButton) {
        self.presentingViewController?.dismiss(animated: true, completion: {
            
        })
    }
    
    func cells(for tableView: UITableView) -> [DeviceAddDeviceTableViewCell]? {
        let sections: Int = tableView.numberOfSections
        var cells: [DeviceAddDeviceTableViewCell] = []
        for section in 0..<sections {
            let rows: Int = tableView.numberOfRows(inSection: section)
            for row in 0..<rows {
                let indexPath = IndexPath(row: row, section: section)
                if let aPath = tableView.cellForRow(at: indexPath){
                    cells.append(aPath as! DeviceAddDeviceTableViewCell)
                }
            }
        }
        return cells
    }
}

extension FilesConflictAlertViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:DeviceAddDeviceTableViewCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DeviceAddDeviceTableViewCell
        cell.selectionStyle = .none
     
        cell.accessoryType = .none
        tableView.separatorStyle = .none
        switch indexPath.row {
        case 0:
            cell.nameLabel.text = LocalizedString(forKey: "保留")
        case 1:
            cell.nameLabel.text = LocalizedString(forKey: "替换")
        case 2:
            cell.nameLabel.text = LocalizedString(forKey: "跳过")
        default:
           break
        }
        
        cell.disabled = false
        cell.detailLabel.text = nil
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        for (i,value) in (cells(for: tableView)?.enumerated())! {
            if i != indexPath.row {
                value.isSelected = false
            } else if i == indexPath.row {
                value.isSelected = true
            }
        }
        
       
        let selectedType = actions[indexPath.row]
        self.selectType = selectedType.rawValue
    }
}

