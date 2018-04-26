//
//  DiskErrorViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/26.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MDCAlertController

enum DiskMakeUpType:Int {
    case single = 0
    case RAID1
}

private let LineMargins:CGFloat = 392/2
private let ImageSize:CGSize = (UIImage.init(named: "disk_main_color.png")?.size)!


class DiskErrorViewController: BaseViewController {
    var normalDiskArray:Array<DiskModel>?
    var errorDiskArray:Array<DiskModel>?
    var tipLabel:UILabel?
    var diskMakeUpType:DiskMakeUpType?{
        didSet{
            switch diskMakeUpType {
            case .single?:
                diskSingleAction()
            case .RAID1?:
                diskRAID1Action()
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizedString(forKey: "磁盘丢失")
        addNavigationItemBar()
        setData()
        view.addSubview(lineView)
        view.addSubview(diskMakeUpTypeTitleLabel)
        view.addSubview(diskMakeUpTypeContentLabel)
        view.addSubview(diskScrollView)
        setDiskView()
        view.addSubview(leftWarningImageView)
        view.addSubview(warningTitleLabel)
        setDiskErrorInfo()
        view.addSubview(continueButton)
    }
    
    func setData() {
        normalDiskArray = Array.init()
        let diskModel1 = DiskModel.init()
        diskModel1.name = "Disk1"
        diskModel1.capacity = 2.0
        diskModel1.isError = false
        
        let diskModel2 = DiskModel.init()
        diskModel2.name = "Disk2"
        diskModel2.capacity = 1.0
        diskModel2.isError = true
        diskModel2.serial = "ABCDUIPEL1J"
    
        let diskModel3 = DiskModel.init()
        diskModel3.name = "Disk3"
        diskModel3.capacity = 3.0
        diskModel3.isError = true
        diskModel3.serial = "DACDUDAS1J"
        normalDiskArray = [diskModel1,diskModel2,diskModel3]
        errorDiskArray = Array.init()
        for value in normalDiskArray! {
            if value.isError! {
                errorDiskArray?.append(value)
            }
        }
        diskMakeUpType = .single
    }
    
    func setDiskView(){
         diskScrollView.contentSize = CGSize(width: __kWidth*CGFloat((normalDiskArray?.count)!), height: diskScrollView.height)
        for (idx,value) in (normalDiskArray?.enumerated())! {
            View_Width = ImageSize.width
            View_Width_Space = MarginsCloseWidth
            View_Start_X = MarginsWidth
            View_Start_Y = 0
            
            let diskView = UIView.init(frame: CGRect(x: CGFloat(idx) * (View_Width + View_Width_Space) + View_Start_X , y: View_Start_Y, width: View_Width, height: View_Width))
            diskView.layer.masksToBounds = true
            diskView.layer.borderWidth = 1
            diskView.layer.borderColor = COR1.withAlphaComponent(0.1).cgColor
            let imageName = value.isError! ? "disk_error.png":"disk_main_color.png"
            let cgImage = UIImage.init(named: imageName)?.cgImage
            diskView.layer.contents = cgImage
            diskScrollView.addSubview(diskView)
            
            let model = value
            let font = SmallTitleFont
            let height = labelHeightFrom(title: model.name!, font: font)
            let width = labelWidthFrom(title: model.name!, font: font)
            let label = UILabel.init(frame: CGRect(x: 0 ,y: 0, width: width, height: height))
            label.center =  CGPoint(x: diskView.center.x, y: diskView.center.y + diskView.height/2 + MarginsCloseWidth)
            label.font = font
            label.text = value.name!
            label.textColor = LightGrayColor
            label.textAlignment = NSTextAlignment.center
            diskScrollView.addSubview(label)
        }
    }
    
    func setDiskErrorInfo(){
        var label:UILabel?
        View_Start_Y = leftWarningImageView.bottom + MarginsFarWidth
        View_Width = 6
        View_Height = MiddleTitleFont.lineHeight
        View_Height_Space = MarginsCloseWidth
        
        for (idx,value) in (errorDiskArray?.enumerated())! {
            let pointView = UIView.init(frame: CGRect(x: MarginsWidth, y:  CGFloat(idx) * (View_Height + View_Height_Space) + View_Start_Y, width: View_Width, height: View_Height))
            
            let shapeLayer = CAShapeLayer.init()
            
            let path = UIBezierPath.init(arcCenter: CGPoint(x: View_Width/2, y: View_Height/2), radius: 2, startAngle: 0, endAngle:CGFloat(2*Double.pi), clockwise: false)
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = UIColor.black.cgColor
            pointView.layer.addSublayer(shapeLayer)
            view.addSubview(pointView)
            
            label = UILabel.init(frame: CGRect(x: pointView.right + MarginsCloseWidth, y: CGFloat(idx) * (View_Height + View_Height_Space) + View_Start_Y, width: __kWidth - pointView.right + MarginsCloseWidth - MarginsWidth, height: View_Height))
            label?.font = MiddleTitleFont
            label?.textColor = DarkGrayColor
            let text = LocalizedString(forKey: "序列号")
            label?.text = "\(String(describing: value.name!))  \(String(describing: value.capacity!))TB  \(text):\(String(describing: value.serial!))"
            label?.tag = idx
            view.addSubview(label!)
        }
        let trueLabel = label?.viewWithTag((errorDiskArray?.count)!-1)
//        if (trueLabel != nil) {
            let bottom = trueLabel?.bottom ?? leftWarningImageView.bottom
            let y = bottom + MarginsWidth
            let text1 = LocalizedString(forKey: "*可能磁盘插口松动，请关机取出磁盘并重新插入。")
            let text2 = LocalizedString(forKey: "*也可能磁盘损坏")
            let font = SmallTitleFont
            let tipLabel1 = UILabel.init(frame: CGRect(x: MarginsWidth, y: y, width: NormalLabelWidth,height: labelHeightFrom(title: text1, font: font)))
            tipLabel1.text = text1
            tipLabel1.textColor = LightGrayColor
            tipLabel1.font = font
            tipLabel1.numberOfLines = 0
            tipLabel1.lineBreakMode = .byWordWrapping
            tipLabel1.sizeToFit()
        
            let tipLabel2 = UILabel.init(frame: CGRect(x: MarginsWidth, y: tipLabel1.bottom + MarginsCloseWidth, width: NormalLabelWidth,height:labelSize(title: text1, font: font).height ))
            tipLabel2.text = text2
            tipLabel2.textColor = LightGrayColor
            tipLabel2.font = font
            tipLabel2.numberOfLines = 0
            tipLabel2.lineBreakMode = .byWordWrapping
            tipLabel2.sizeToFit()
            view.addSubview(tipLabel1)
            view.addSubview(tipLabel2)
            tipLabel = tipLabel2
//        }
    }
    
    func diskSingleAction() {
        diskMakeUpTypeContentLabel.text = LocalizedString(forKey: "Single")
    }
    
    func diskRAID1Action() {
        diskMakeUpTypeContentLabel.text = LocalizedString(forKey: "RAID1")
    }

    func addNavigationItemBar() {
        let leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "close.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(leftBarButtonItemClick(_ :)))
        appBar.navigationBar.leftBarButtonItem = leftBarButtonItem
        
        let rightBarButtonItem = UIBarButtonItem.init(title: LocalizedString(forKey: "power_off"), style: UIBarButtonItemStyle.plain, target: self, action:#selector(rightBarButtonItemClick(_ :)))
        appBar.navigationBar.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc func leftBarButtonItemClick(_ sender:UIBarButtonItem){
        self.dismiss(animated: true) {
            
        }
    }
    
    @objc func rightBarButtonItemClick(_ sender:UIBarButtonItem){
        
    }
    
    @objc func continueButtonClick(_ sender:UIButton){
        Alert.alert(title: LocalizedString(forKey: "继续使用？"), message: LocalizedString(forKey: "丢失磁盘的数据将无法找回"), action1Title: LocalizedString(forKey: "cancel"), action2Title: "sure", handler1: { (alertAction) in
            
        }) { (alertAction) in
            
        }
    }
    
    lazy var lineView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: MDCAppNavigationBarHeight + LineMargins, width: __kWidth, height: 1))
        view.backgroundColor = WhiteGrayColor
        return view
    }()
    
    lazy var diskMakeUpTypeContentLabel: UILabel = {
        let font = MiddleTitleFont
        let height = font.lineHeight + 2
        let label = UILabel.init(frame: CGRect.init(x: MarginsWidth, y:diskMakeUpTypeTitleLabel.top - MarginsCloseWidth - height , width: __kWidth - MarginsWidth*2, height: height))
        label.font = font
        label.textColor = DarkGrayColor
        return label
    }()
    
    lazy var diskMakeUpTypeTitleLabel: UILabel = {
        let text = LocalizedString(forKey: "模式")
        let font = SmallTitleFont
        let height = labelHeightFrom(title: text, font: font)
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: lineView.top - MarginsWidth - height, width: __kWidth - MarginsWidth*2, height: height))
        label.text = text
        label.font = font
        label.textColor = GrayColor
        return label
    }()
    
    lazy var diskScrollView: UIScrollView = {
        let height = ImageSize.height + MarginsCloseWidth + SmallTitleFont.lineHeight + 2
        let scrollView = UIScrollView.init(frame: CGRect(x: 0, y: diskMakeUpTypeContentLabel.top - MarginsSoFarWidth - height, width: __kWidth, height: height))
        return scrollView
    }()
    
    lazy var leftWarningImageView: UIImageView = {
        let image = UIImage.init(named: "warning.png")
        let imageView = UIImageView.init(frame: CGRect(x: MarginsWidth, y: MarginsSoFarWidth + lineView.bottom, width: (image?.size.width)!, height: (image?.size.height)!))
        imageView.image = image
        return imageView
    }()
    
    lazy var warningTitleLabel: UILabel = {
        let font = TitleFont18
        let text = LocalizedString(forKey: "丢失的磁盘")
        let height = labelHeightFrom(title: text, font: font)
        let label = UILabel.init(frame: CGRect(x: leftWarningImageView.right + MarginsWidth, y: leftWarningImageView.top, width: __kWidth - leftWarningImageView.right + MarginsWidth - MarginsWidth, height: height))
        label.text = text
        label.textColor = DarkGrayColor
        label.font = font
        return label
    }()
    
    lazy var continueButton: UIButton = {
        let text = LocalizedString(forKey: "继续使用")
        let font = SmallTitleFont
        let width = labelSize(title: text, font: font).width + 6
        let button = UIButton.init(frame: CGRect(x: __kWidth - MarginsWidth - width, y: (tipLabel?.bottom)! + MarginsSoFarWidth, width: width, height: labelSize(title: text, font: font).height + 4))
        button.setTitle(text, for: UIControlState.normal)
        button.titleLabel?.font = font
        button.addTarget(self, action: #selector(continueButtonClick(_:)), for: UIControlEvents.touchUpInside)
        button.setTitleColor(COR1, for: UIControlState.normal)
        return button
    }()
//repair
}
