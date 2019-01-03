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

//旧版搜索设备弹窗（已废弃）
class DiskPopUpViewManager: NSObject {
    var popupController:CNPPopupController?
    var diskArray:Array<DiskModel>?
    var stationModel:CloadLoginUserRemotModel?
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
        super.init()
        diskArray = []
    }
    
    
    func showPopupWithStyle(_ state:DeviceForSearchState, _ popupStyle: CNPPopupStyle, diskArray:Array<DiskModel>, stationModel:CloadLoginUserRemotModel) {
   
        self.diskArray = diskArray
        self.stationModel = stationModel
        self.state = state
        var contentArray:Array<UIView> = []
        
        switch state{
        case .applyToUse:
            popUpTableView.frame = CGRect(x: 0, y: TopViewHeight, width: TopViewWidth, height: CGFloat(3 + 1) * TableViewCellHeight + TableViewHeaderHeight)
            contentArray.append(popUpTableView)
        default:
             popUpTableView.frame = CGRect(x: 0, y: TopViewHeight, width: TopViewWidth, height: CGFloat(4+1) * TableViewCellHeight + TableViewHeaderHeight)
             let line = UIView.init(frame: CGRect(x: 0, y: 0, width: TopViewWidth, height: 1))
             line.backgroundColor = LightLineColor
             if #available(iOS 11.0, *) {
                popUpTableView.contentInsetAdjustmentBehavior = .never
             } else {
                // Fallback on earlier versions
             }
             
             let bgView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: TopViewWidth, height: 72/2))
             let rightButton = UIButton.init(frame: CGRect.init(x: TopViewWidth - 128/2 - MarginsSoFarWidth, y: 0, width: 128/2 , height: 72/2 ))
             let title = LocalizedString(forKey: "got_it")
             rightButton.setTitleColor(COR1, for: UIControlState.normal)
             rightButton.setTitle(title, for: UIControlState.normal)
             rightButton.titleLabel?.font = SmallTitleFont
            rightButton.addTarget(self, action: #selector(reinitButtonClick(_ :)), for: UIControlEvents.touchUpInside)
             bgView.addSubview(rightButton)
             
             let text = LocalizedString(forKey: "不，我要重新初始化")
             let attributedString = NSMutableAttributedString.init(string: text)
             let strRange = NSRange.init(location: 0, length: attributedString.length)
             attributedString.setUnderlineStyle(NSUnderlineStyle.styleSingle, range: strRange)
             attributedString.setColor(LightGrayColor, range: strRange)
             attributedString.setUnderlineColor(LightGrayColor, range: strRange)
             let leftButton = UIButton.init(frame: CGRect.init(x: MarginsSoFarWidth, y: 0, width: labelWidthFrom(title: text, font: SmallTitleFont) + 4 , height: 72/2 ))
             leftButton.setAttributedTitle(attributedString, for: UIControlState.normal)
             leftButton.setTitleColor(LightGrayColor, for: UIControlState.normal)
             leftButton.titleLabel?.font = SmallTitleFont
             
             leftButton.addTarget(self, action: #selector(reinitButtonClick(_ :)), for: UIControlEvents.touchUpInside)
             bgView.addSubview(leftButton)
             contentArray.append(popUpTableView)
             contentArray.append(line)
             contentArray.append(bgView)
        }
        
        let popupController = CNPPopupController(contents:contentArray)
        popupController.theme = CNPPopupTheme.default()
        popupController.theme.popupStyle = popupStyle
        // LFL added settings for custom color and blur
        popupController.delegate = self
        self.popupController = popupController
        popupController.present(animated: true)
    }
    
    @objc func reinitButtonClick(_ sender:UIButton){
        self.popupController?.dismiss(animated: true)
    }
    
    lazy var popUpTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect(x: 0, y: TopViewHeight, width: TopViewWidth, height: CGFloat(((diskArray?.count)! + 1)) * TableViewCellHeight + TableViewHeaderHeight), style: UITableViewStyle.plain)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        tableView.bounces = false
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
        switch state {
        case .applyToUse?:
            return (diskArray?.count)!*3
        default:
            return (diskArray?.count)!*4
        }
     
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
            let index = indexPath.row/3
            switch indexPath.row % 3{
            case 0 :
                cell?.leftImageView.image = UIImage.init(named: "account")
                cell?.titleLabel.text = diskArray?[index].admin
                cell?.detailLabel.text = LocalizedString(forKey: "admin")
            case 1 :
                cell?.leftImageView.image = UIImage.init(named: "diskinit")
                let text:String  = String(describing:(diskArray?[index].effectiveCapacity!)!)
                cell?.titleLabel.text = "\(text)TB"
                cell?.detailLabel.text = LocalizedString(forKey: "可用容量")
            case 2 :
                let text:String  = String(describing:(diskArray?[index].capacity!)!)
                cell?.titleLabel.text = "\(text)TB"
                cell?.detailLabel.text = LocalizedString(forKey: "总容量")
                cell?.leftImageView.isHidden = true
            default:
                break
            }
            
            return cell!
        case .importTo?:
            tableView.register(UINib.init(nibName: "InitLastViewCardViewTableViewCell", bundle: nil), forCellReuseIdentifier: TableViewCellIdentifer)
            var cell:RadioButtonTableViewCell? = (tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifer) as? RadioButtonTableViewCell)
            if cell == nil{
                cell = Bundle.main.loadNibNamed(String.init(describing: RadioButtonTableViewCell.self), owner: nil, options: nil)?.last as? RadioButtonTableViewCell
            }
            cell?.selectionStyle = .none
            let index = indexPath.row/4
            let tag = (index + 1)*1000
//            print("😆\(tag)")
            cell?.tableView = tableView
            switch indexPath.row % 4{
            case 0 :
                cell?.radioButton.tag = tag
                if cell?.radioButton.tag == 1000{
                    cell?.radioButton.setSelected(true)
                }
                
//                print(cell?.radioButton.groupButtons ?? [])
                cell?.titleLabel.text = diskArray?[index].admin
                cell?.detailLabel.text = LocalizedString(forKey: "原设备名")
            case 1 :
                cell?.radioButton.isHidden = true
                let text:String  = String(describing:(diskArray?[index].type!)!)
                cell?.titleLabel.text = text
                cell?.detailLabel.text = LocalizedString(forKey: "磁盘模式")
            case 2 :
//                let text:String  = String(describing:(diskArray?[index].capacity!)!)
                cell?.titleLabel.text = "1/2"
                cell?.detailLabel.text = LocalizedString(forKey: "磁盘数")
                cell?.radioButton.isHidden = true
            case 3 :
                let text:String  = "\(String(describing:(diskArray?[index].effectiveCapacity!)!))/\(String(describing:(diskArray?[index].capacity!)!)) TB"
                cell?.titleLabel.text = text
                cell?.detailLabel.text = LocalizedString(forKey: "磁盘空间")
                cell?.radioButton.isHidden = true
            default:
                break
            }
            
            return cell!
        default:
            tableView.register(UINib.init(nibName: "InitLastViewCardViewTableViewCell", bundle: nil), forCellReuseIdentifier: TableViewCellIdentifer)
            let cell:InitLastViewCardViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifer) as! InitLastViewCardViewTableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TableViewCellHeight
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let text = LocalizedString(forKey: "发现其他闻上设备已用磁盘，我要使用：")
        let view = UIView.init()
        view.backgroundColor = UIColor.white
        let label = UILabel.init(frame: CGRect(x: MarginsSoFarWidth, y: 0 , width: TopViewWidth - MarginsSoFarWidth, height: TableViewHeaderHeight))
        label.font = SmallTitleFont
        label.textColor = LightGrayColor
        label.text = text
        view.addSubview(label)
        return view
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return LocalizedString(forKey: "发现其他闻上设备已用磁盘，我要使用：")
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableViewHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}

extension DiskPopUpViewManager : CNPPopupControllerDelegate {
    func nameString() -> String! {
        return stationModel?.name
    }
    
    func addressString() -> String! {
        return stationModel?.LANIP
    }
    
    
    func popupControllerWillDismiss(_ controller: CNPPopupController) {
        print("Popup controller will be dismissed")
    }
    
    func popupControllerDidPresent(_ controller: CNPPopupController) {
        print("Popup controller presented")
    }
    
}
