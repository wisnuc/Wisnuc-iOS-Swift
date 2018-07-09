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
private let checkBoxWidth:CGFloat = 18

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
        diskSettingCardView.addSubview(selectDiskDetailButton)
        diskSettingCardView.addSubview(cardLineView)
        switch diskArray?.count {
        case 0:
            break
        case 1 :
            diskSettingCardView.addSubview(diskCombinationSingleRadioButton)
        default:
            diskSettingCardView.addSubview(diskCombinationSingleRadioButton)
            diskSettingCardView.addSubview(diskCombinationRAID1RadioButton)
        }
        
        diskAllCapacityDisplayLabel.text = "3.93TB"
        diskAllCapacityDisplayLabel.sizeToFit()
        
        diskAvailableCapacityDisplayLabel.text = "1.96TB"
        diskAvailableCapacityDisplayLabel.sizeToFit()
        
        diskSettingCardView.addSubview(diskAllCapacityDisplayLabel)
        diskSettingCardView.addSubview(diskAllCapacityTitleLabel)
        diskSettingCardView.addSubview(diskAvailableCapacityDisplayLabel)
        diskSettingCardView.addSubview(diskAvailableCapacityTitleLabel)
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
        setSelectDiskCheckBox(center: label.center, idx: idx,model: model)
    }
    
    func setSelectDiskCheckBox(center:CGPoint,idx:Int,model:DiskModel) {
        let font = BoldMiddlePlusTitleFont
        let checkBox = BEMCheckBox.init(frame:CGRect(x: 0, y: 0, width: checkBoxWidth, height: checkBoxWidth))
        checkBox.center = CGPoint(x: center.x, y: center.y + checkBoxWidth/2 + MarginsCloseWidth +  labelHeightFrom(title: model.name!, font: font)/2)
        checkBox.boxType = BEMBoxType.square
        checkBox.onAnimationType = BEMAnimationType.bounce
        checkBox.offAnimationType = BEMAnimationType.bounce
        checkBox.onFillColor = UIColor.white
        checkBox.onTintColor = UIColor.white
        checkBox.onCheckColor = COR1
        checkBox.tintColor = UIColor.white
        checkBox.delegate = self
        checkBox.tag = idx
        self.view.addSubview(checkBox)
    }

    @IBAction func nextButtonClick(_ sender: MDCButton) {
        let creatUserVC = InitializationCreatUserViewController.init()
        self.navigationController?.pushViewController(creatUserVC, animated: true)
    }
    
    @objc func radioButtonClick(_ sender: WSRadioButton){
    
    }
    
    @objc func selectDiskDetailButtonClick(_ sender: UIButton){
        
    }
    
    lazy var backgroudView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: MDCAppNavigationBarHeight, width: __kWidth, height: __kHeight/2  - MDCAppNavigationBarHeight))
        view.backgroundColor = COR1
        return view
    }()
    
    lazy var diskSettingCardView: UIView = {
        let cardView = UIView.init(frame: CGRect(x: MarginsCloseWidth, y: backgroudView.bottom - 104/2, width: __kWidth - MarginsCloseWidth*2, height: __kHeight - backgroudView.bottom - 104/2))
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
    
    lazy var selectDiskDetailButton: UIButton = {
        let button = UIButton.init(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        button.center = CGPoint(x: selectDiskTitleLabel.right + MarginsCloseWidth + button.width/2, y: selectDiskTitleLabel.center.y)
        button.setImage(UIImage.init(named: "help.png"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(selectDiskDetailButtonClick(_:)), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var diskCombinationSingleRadioButton: WSRadioButton = {
        let text = "SINGLE"
        let font = MiddleTitleFont
        let radioButton = WSRadioButton.init(frame: CGRect(x: MarginsWidth, y: cardLineView.bottom - 22 - checkBoxWidth , width: checkBoxWidth + labelWidthFrom(title: text, font: font ) + 10, height: checkBoxWidth))
        radioButton.setImage(UIImage.init(named: "radio_button"), for: UIControlState.selected)
        radioButton.setImage(UIImage.init(named: "radio_button_unchecked"), for: UIControlState.normal)
        radioButton.setTitleColor(LightGrayColor, for: UIControlState.normal)
        radioButton.setSelected(true)
        radioButton.tag = 1000
        radioButton.setTitle(text, for: UIControlState.normal)
        radioButton.titleLabel?.font = font
        radioButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        radioButton.addTarget(self, action: #selector(radioButtonClick(_ :)), for: UIControlEvents.touchUpInside)
        return radioButton
    }()
    
    lazy var diskCombinationRAID1RadioButton: WSRadioButton = {
        let text = "RAID1"
        let font = MiddleTitleFont
        let radioButton = WSRadioButton.init(frame: CGRect(x: diskCombinationSingleRadioButton.right + 44, y: diskCombinationSingleRadioButton.top, width: checkBoxWidth + labelWidthFrom(title: text, font: font ) + 10, height: checkBoxWidth))
        radioButton.addTarget(self, action: #selector(radioButtonClick(_ :)), for: UIControlEvents.touchUpInside)
        radioButton.groupButtons = [diskCombinationSingleRadioButton]
        radioButton.setImage(UIImage.init(named: "radio_button"), for: UIControlState.selected)
        radioButton.setImage(UIImage.init(named: "radio_button_unchecked"), for: UIControlState.normal)
        radioButton.setTitleColor(LightGrayColor, for: UIControlState.normal)
        radioButton.setTitle(text, for: UIControlState.normal)
        radioButton.titleLabel?.font = font
        radioButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        radioButton.tag = 2000
        return radioButton
    }()
    
    lazy var cardLineView: UIView = {
        let view = UIView.init(frame: CGRect(x: 0, y: diskSettingCardView.height/2 - 30, width: diskSettingCardView.width, height: 1))
        view.backgroundColor = Gray26Color
        return view
    }()
    
    lazy var diskAllCapacityDisplayLabel: UILabel = {
        let text = ""
        let font = MiddlePlusTitleFont
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: cardLineView.bottom + 18, width: labelWidthFrom(title: text, font: font), height: labelHeightFrom(title: text, font: font)))
        label.textColor = DarkGrayColor
        
        return label
    }()
    
    lazy var diskAllCapacityTitleLabel: UILabel = {
        let text =  LocalizedString(forKey: "磁盘容量总和")
        let font = SmallTitleFont
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: diskAllCapacityDisplayLabel.bottom + MarginsCloseWidth, width: diskSettingCardView.width - MarginsWidth*2, height: labelHeightFrom(title: text, font: font)))
        label.text = text
        label.textColor = LightGrayColor
        return label
    }()
    
    lazy var diskAvailableCapacityDisplayLabel: UILabel = {
        let text = ""
        let font = MiddlePlusTitleFont
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: diskAllCapacityTitleLabel.bottom + MarginsFarWidth, width: labelWidthFrom(title: text, font: font), height: labelHeightFrom(title: text, font: font)))
        label.textColor = DarkGrayColor
        return label
    }()
    
    lazy var diskAvailableCapacityTitleLabel: UILabel = {
        let text = LocalizedString(forKey: "可用容量")
        let font = MiddleTitleFont
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: diskAvailableCapacityDisplayLabel.bottom + MarginsCloseWidth, width: diskSettingCardView.width - MarginsWidth*2, height: labelHeightFrom(title: text, font: font)))
        label.text = text
        label.textColor = LightGrayColor
        return label
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension InitializationDiskViewController : BEMCheckBoxDelegate{
    func didTap(_ checkBox: BEMCheckBox) {
        
    }
}
