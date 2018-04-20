//
//  InitializationDiskViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/20.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents
import BEMCheckBox

private let InitMarginsTop:CGFloat = 24

class InitializationDiskViewController: BaseViewController {

    @IBOutlet weak var nextButton: MDCButton!
    var diskArray:Array<DiskModel>?
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
        baseSetting()
        setDisk()
    }
    
    func setData(){
        diskArray = Array.init()
        let diskModel1 = DiskModel.init()
        diskModel1.type = "ext"
        diskModel1.name = "disk1"
        let diskModel2 = DiskModel.init()
        diskModel2.type = "ext"
        diskModel2.name = "disk2"
        diskArray?.append(diskModel1)
        diskArray?.append(diskModel2)
    }
    
    func baseSetting() {
        self.view.backgroundColor = lightGrayBackgroudColor
        nextButton.setBackgroundColor(COR1)
        nextButton.setTitle(LocalizedString(forKey: "next_step"), for: UIControlState.normal)
        view.addSubview(backgroudView)
        view.addSubview(diskSettingCardView)
        view.addSubview(selectDiskLabel)
    }
    
    func setDisk() {
        for (idx,value) in (diskArray?.enumerated())! {
            let model = value
            setDiskImageView(idx: idx,model:model)
        }
        
        diskSettingCardView.addSubview(selectDiskTitleLabel)
    }
    
    func setDiskImageView(idx:Int,model:DiskModel)  {
        let image = UIImage.init(named: "disk.png")
        View_Start_X = MarginsWidth
        View_Start_Y = selectDiskLabel.bottom + InitMarginsTop
        View_Width_Space = 8
        View_Height = (image?.size.height)!
        View_Width = (image?.size.width)!
        let diskImageView = UIImageView.init(frame:CGRect(x: CGFloat(idx) * (View_Width + View_Width_Space) + View_Start_X, y: View_Start_Y, width: View_Width, height: View_Height))
        diskImageView.image = image
        diskImageView.layer.borderColor = Gray26Color.cgColor
        diskImageView.layer.borderWidth = 1
        self.view.addSubview(diskImageView)
        setDiskNameLabel(center: diskImageView.center, model: model, idx: idx)
    }
    
    func setDiskNameLabel(center:CGPoint,model:DiskModel,idx:Int) {
        let image = UIImage.init(named: "disk.png")
         View_Width = (image?.size.width)!
        let font = BoldMiddlePlusTitleFont
        let label = UILabel.init(frame: CGRect(x: 0, y: 0, width: labelWidthFrom(title: model.name!, font: font) + 5, height: labelHeightFrom(title: model.name!, font: font)))
        label.center = CGPoint(x: center.x, y: center.y + View_Width/2 + MarginsCloseWidth + label.height/2)
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.text = model.name!
        label.font = font
        self.view.addSubview(label)
//        setSelectDiskCheckBox(center: label.center, idx: idx)
    }
    
//    func setSelectDiskCheckBox(center:CGPoint,idx:Int) {
//        let checkBox = BEMCheckBox.init(frame:CGRect(x: 0, y: 0, width: 16, height: 16))
//        checkBox.center = CGPoint(x: center.x, y: center.y +  + MarginsCloseWidth + )
//        self.view.addSubview(checkBox)
//    }

    @IBAction func nextButtonClick(_ sender: MDCButton) {
        let creatUserVC = InitializationCreatUserViewController.init()
        self.navigationController?.pushViewController(creatUserVC, animated: true)
    }
    
    lazy var backgroudView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: MDCAppNavigationBarHeight, width: __kWidth, height: __kHeight/2 - MDCAppNavigationBarHeight))
        view.backgroundColor = COR1
        return view
    }()
    
    lazy var diskSettingCardView: UIView = {
        let cardView = UIView.init(frame: CGRect(x: MarginsCloseWidth, y: backgroudView.bottom - 184/2, width: __kWidth - MarginsCloseWidth*2, height: __kHeight - backgroudView.bottom - 184/2))
        cardView.backgroundColor = UIColor.white
        cardView.layer.masksToBounds = true
        cardView.layer.cornerRadius = 2
        cardView.layer.shadowColor = LightGrayColor.cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset = CGSize.zero
        cardView.layer.shadowRadius = 2
        cardView.clipsToBounds = false
        return cardView
    }()
    
    lazy var selectDiskLabel: UILabel = {
        let text = LocalizedString(forKey: "选择磁盘使用模式")
        let font = SmallTitleFont
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: InitMarginsTop + MDCAppNavigationBarHeight, width: __kWidth - MarginsWidth*2, height: labelHeightFrom(title: text, font: font)))
        label.textColor = WhiteGrayColor
        label.text = text
        label.font = font
        return label
    }()
    
    lazy var selectDiskTitleLabel: UILabel = {
        let text = LocalizedString(forKey: "选择模式")
        let font = MiddleTitleFont
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: MarginsCloseWidth, width: labelWidthFrom(title: text, font: font) , height: 96/2))
        label.text = text
        label.font = font
        label.textColor = DarkGrayColor
        return label
    }()
    
//    lazy var diskCombinationSingleCheckBox: BEMCheckBox = {
//        let checkBox = BEMCheckBox.init(frame: )
//        return <#value#>
//    }()
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
