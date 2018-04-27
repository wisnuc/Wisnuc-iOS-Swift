//
//  DiskPopUpViewManager.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/27.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

private let TopViewWidth:CGFloat =  __kWidth - MarginsWidth*2
private let TopViewHeight:CGFloat = 204/2
private let TableViewCellHeight:CGFloat = 112/2
private let TableViewCellIdentifer = "celled"
private let TableViewHeaderHeight:CGFloat = 80/2

class DiskPopUpViewManager: NSObject {
    var popupController:CNPPopupController?
    var diskArray:Array<DiskModel>?
    var stationModel:StationModel?
    var state:DeviceForSearchState?{
        didSet{
            switch state {
            case .applyToUse?:
                break
            case .initialization?:
                break
            case .importTo?:
                break
            default:
               break
            }
        }
    }
    
    static let sharedInstance = DiskPopUpViewManager()
    private override init(){
        diskArray = []
    }
    
    
    func showPopupWithStyle(_ state:DeviceForSearchState, _ popupStyle: CNPPopupStyle, diskArray:Array<DiskModel>, stationModel:StationModel) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraphStyle.alignment = NSTextAlignment.center
        
        let title = NSAttributedString(string: "It's A Popup!", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 24), NSAttributedStringKey.paragraphStyle: paragraphStyle])
        let lineOne = NSAttributedString(string: "You can add text and images", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18), NSAttributedStringKey.paragraphStyle: paragraphStyle])
        let lineTwo = NSAttributedString(string: "With style, using NSAttributedString", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18), NSAttributedStringKey.foregroundColor: UIColor.init(red: 0.46, green: 0.8, blue: 1.0, alpha: 1.0), NSAttributedStringKey.paragraphStyle: paragraphStyle])
        
        let button = CNPPopupButton.init(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitle("Close Me", for: UIControlState())
        
        button.backgroundColor = UIColor.init(red: 0.46, green: 0.8, blue: 1.0, alpha: 1.0)
        
        button.layer.cornerRadius = 4;
        button.selectionHandler = { (button) -> Void in
            self.popupController?.dismiss(animated: true)
            print("Block for button: \(String(describing: button.titleLabel?.text))")
        }
        
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0;
        titleLabel.attributedText = title
        
        let lineOneLabel = UILabel()
        lineOneLabel.numberOfLines = 0;
        lineOneLabel.attributedText = lineOne;
        
        let imageView = UIImageView.init(image: UIImage.init(named: "icon"))
        
        let lineTwoLabel = UILabel()
        lineTwoLabel.numberOfLines = 0;
        lineTwoLabel.attributedText = lineTwo;
        
        let customView = UIView.init(frame: CGRect(x: 0, y: 0, width: 250, height: 55))
        customView.backgroundColor = UIColor.lightGray
        
        let textField = UITextField.init(frame: CGRect(x: 10, y: 10, width: 230, height: 35))
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.placeholder = "Custom view!"
        customView.addSubview(textField)

        self.diskArray = diskArray
        self.stationModel = stationModel
        self.state = state
        switch state{
        case .applyToUse:
            popUpTableView.frame = CGRect(x: 0, y: TopViewHeight, width: TopViewWidth, height: CGFloat(diskArray.count*3) * TableViewCellHeight + TableViewHeaderHeight)
        default:
             popUpTableView.frame = CGRect(x: 0, y: TopViewHeight, width: TopViewWidth, height: CGFloat(diskArray.count*4+1) * TableViewCellHeight + TableViewHeaderHeight)
        }
        let popupController = CNPPopupController(contents:[popUpTableView])
        popupController.theme = CNPPopupTheme.default()
        popupController.theme.popupStyle = popupStyle
        // LFL added settings for custom color and blur
        popupController.delegate = self
        self.popupController = popupController
        popupController.present(animated: true)
    }
    
    lazy var popUpTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect(x: 0, y: TopViewHeight, width: TopViewWidth, height: CGFloat(((diskArray?.count)! + 1)) * TableViewCellHeight + TableViewHeaderHeight), style: UITableViewStyle.grouped)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        return tableView
    }()
}

extension DiskPopUpViewManager : UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension DiskPopUpViewManager : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (diskArray?.count)!*3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorStyle = .none
        switch state {
        case .applyToUse?:
//
            var cell:InitLastViewCardViewTableViewCell? = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifer ) as? InitLastViewCardViewTableViewCell
    
            if cell == nil{
                cell = Bundle.main.loadNibNamed(String.init(describing: InitLastViewCardViewTableViewCell.self), owner: nil, options: nil)?.last as? InitLastViewCardViewTableViewCell
            }
            cell?.selectionStyle = .none
            switch indexPath.row % 3{
            case 0 :
                cell?.leftImageView.image = UIImage.init(named: "account")
//              cell.titleLabel.text = diskArray[]
            case 1 :
                cell?.leftImageView.image = UIImage.init(named: "diskinit")
            case 2 :
                cell?.titleLabel.text = "diskArray[]"
                cell?.leftImageView.isHidden = true
            default:
                break
            }
            
            return cell!
        case .initialization?:
            tableView.register(UINib.init(nibName: "InitLastViewCardViewTableViewCell", bundle: nil), forCellReuseIdentifier: TableViewCellIdentifer)
            let cell:InitLastViewCardViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifer) as! InitLastViewCardViewTableViewCell
            return cell
        case .importTo?:
            tableView.register(UINib.init(nibName: "InitLastViewCardViewTableViewCell", bundle: nil), forCellReuseIdentifier: TableViewCellIdentifer)
            let cell:InitLastViewCardViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifer) as! InitLastViewCardViewTableViewCell
            return cell
        default:
            tableView.register(UINib.init(nibName: "InitLastViewCardViewTableViewCell", bundle: nil), forCellReuseIdentifier: TableViewCellIdentifer)
            let cell:InitLastViewCardViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifer) as! InitLastViewCardViewTableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableViewCellHeight
    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let text = LocalizedString(forKey: "发现其他闻上设备已用磁盘，我要使用：")
//        let view = UIView.init()
//        let label = UILabel.init(frame: CGRect(x: MarginsSoFarWidth, y: 0 , width: TopViewWidth - MarginsSoFarWidth, height: TableViewHeaderHeight))
//        label.font = SmallTitleFont
//        label.textColor = LightGrayColor
//        label.text = text
//        view.addSubview(label)
//        return view
//    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return LocalizedString(forKey: "发现其他闻上设备已用磁盘，我要使用：")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableViewHeaderHeight
    }
}

extension DiskPopUpViewManager : CNPPopupControllerDelegate {
    func nameString() -> String! {
        return stationModel?.name
    }
    
    func addressString() -> String! {
        return stationModel?.adress
    }
    
    
    func popupControllerWillDismiss(_ controller: CNPPopupController) {
        print("Popup controller will be dismissed")
    }
    
    func popupControllerDidPresent(_ controller: CNPPopupController) {
        print("Popup controller presented")
    }
    
}
