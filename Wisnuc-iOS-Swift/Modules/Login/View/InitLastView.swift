//
//  InitLastView.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/25.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
private let BackgroudViewHeight:CGFloat = 488/2
private let ImageTopMargins:CGFloat = 56/2
private let ImageSizeWidth:CGFloat = 210/2
private let BottomButtonBottomMargins:CGFloat = 50/2
private let BottomButtonRightMargins:CGFloat = 50/2
private let CardViewTopMargins:CGFloat = 132/2
private let CardViewHeight:CGFloat = 590/2
private let TableViewDataCount = 5
private let TableViewCellHeight = 112/2
private let TableViewCellId = "celled"

enum InitFinishState:Int{
    case succeed = 0
    case failed
}

protocol InitLastViewDoneDelegate {
    func done()
}

class InitLastView: UIView {
    var delegate:InitLastViewDoneDelegate?
    var state:InitFinishState?{
        didSet{
            switch state {
            case .succeed?:
                succeedAction()
            case .failed?:
                failedAction()
            default:
                break
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    init(state:InitFinishState,frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        setState(state:state)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setState(state:InitFinishState) {
        self.state = state
    }
    
    func succeedAction() {
        self.removeAllSubviews()
        self.addSubview(bgView)
        let image = UIImage.init(named: "ok.png")
        stateImageView.image = image
        self.addSubview(stateImageView)
        stateLabelTitle.text = LocalizedString(forKey: "设备添加成功")
        stateLabelTitle.textColor  = UIColor.white
        self.addSubview(stateLabelTitle)
        self.addSubview(doneButton)
        self.addSubview(infoCardView)
       
        if #available(iOS 11.0, *) {
            infoCardView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
    }
    
    func failedAction() {
        self.removeAllSubviews()
        let image = UIImage.init(named: "no.png")
        stateImageView.image = image
        self.addSubview(stateImageView)
        stateLabelTitle.text = LocalizedString(forKey: "添加失败")
        stateLabelTitle.textColor  = DarkGrayColor
        self.addSubview(stateLabelTitle)
        self.addSubview(failedDetailTitleLabel)
    }
    
    @objc func doneButtonClick(_ sender:UIButton){
        if let delegateOK = delegate {
            delegateOK.done()
        }
    }
    
    lazy var bgView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width:self.width, height: self.height/2 - 44))
        view.backgroundColor = COR1
        return view
    }()
    
    lazy var stateImageView: UIImageView = {
        let imageView = UIImageView.init(frame: CGRect(x: (self.width - ImageSizeWidth)/2, y:ImageTopMargins , width: ImageSizeWidth, height: ImageSizeWidth))
        return imageView
    }()
    
    lazy var stateLabelTitle: UILabel = {
        let label = UILabel.init(frame: CGRect(x: 16, y: stateImageView.bottom + MarginsWidth, width: __kWidth - MarginsWidth * 2, height: 20))
        label.font = MiddlePlusTitleFont
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    lazy var failedDetailTitleLabel: UILabel = {
        let text = LocalizedString(forKey: "请重新尝试或跟换磁盘后再尝试")
        let label = UILabel.init(frame: CGRect(x: 16, y: stateLabelTitle.bottom + MarginsWidth, width: __kWidth - MarginsWidth * 2, height: 20))
        label.font = MiddleTitleFont
        label.textAlignment = NSTextAlignment.center
        label.textColor = LightGrayColor
        label.text = text
        return label
    }()
    lazy var  doneButton: UIButton = {
        let title = LocalizedString(forKey: "知道了")
        let font = MiddleTitleFont
        let width = labelWidthFrom(title: title, font: font)
        let height = labelHeightFrom(title: title, font: font)
        let button = UIButton.init(frame: CGRect(x: __kWidth - BottomButtonRightMargins - width, y: self.height - BottomButtonBottomMargins - height, width: width, height: height))
        button.setTitle(title, for: UIControlState.normal)
        button.titleLabel?.font = font
        button.setTitleColor(COR1, for: UIControlState.normal)
        button.addTarget(self, action: #selector(doneButtonClick(_ :)), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var infoCardView: UITableView = {
        let cardView = UITableView.init(frame: CGRect(x: MarginsWidth, y: bgView.bottom - CardViewTopMargins, width:self.width - MarginsWidth * 2, height: CardViewHeight))
        cardView.backgroundColor = UIColor.white
        cardView.layer.masksToBounds = true
        cardView.layer.cornerRadius = 2
        cardView.layer.shadowColor = LightGrayColor.cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset = CGSize.zero
        cardView.layer.shadowRadius = 2
        cardView.clipsToBounds = false
        cardView.delegate = self
        cardView.dataSource = self
        let nib = UINib(nibName: "InitLastViewCardViewTableViewCell", bundle: nil) //nibName指的是我们创建的Cell文件名
        cardView.register(nib, forCellReuseIdentifier: TableViewCellId)
        cardView.tableFooterView = UIView.init(frame: CGRect.zero)
        cardView.isScrollEnabled = false
        return cardView
    }()
}

extension InitLastView:UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableViewDataCount
    }
}

extension InitLastView:UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:InitLastViewCardViewTableViewCell = tableView.dequeueReusableCell(withIdentifier: TableViewCellId) as! InitLastViewCardViewTableViewCell
        cell.selectionStyle = .none
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        switch indexPath.row {
        case 0:
            cell.titleLabel.text = LocalizedString(forKey: "Mark")
            cell.detailLabel.text = LocalizedString(forKey: "管理员")
            cell.leftImageView.image = UIImage.init(named: "account.png")
        case 1:
            cell.titleLabel.text = LocalizedString(forKey: "2017-5-3")
            cell.detailLabel.text = LocalizedString(forKey: "添加时间")
        case 2:
            cell.titleLabel.text = LocalizedString(forKey: "RAID1")
            cell.detailLabel.text = LocalizedString(forKey: "使用模式")
            cell.leftImageView.image = UIImage.init(named: "diskinit.png")
        case 3:
            cell.titleLabel.text = LocalizedString(forKey: "3.92TB")
            cell.detailLabel.text = LocalizedString(forKey: "总容量")
        case 4:
            cell.titleLabel.text = LocalizedString(forKey: "1.96TB")
            cell.detailLabel.text = LocalizedString(forKey: "可用容量")
        default:
           break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(TableViewCellHeight)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.init()
    }
}
