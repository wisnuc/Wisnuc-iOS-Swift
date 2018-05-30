//
//  MyStationView.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/12.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents

enum StationButtonType :Int {
    case normal = 0
    case offline
    case diskError
    case local
    case poweroff
    case addNew
    case checking
}

private let Width_Space:CGFloat  = MarginsCloseWidth
private let Height_Space:CGFloat  = MarginsCloseWidth
private let ViewWidth:CGFloat  = (__kWidth - MarginsWidth * 2 - MarginsCloseWidth)/2
private let ViewHeight:CGFloat  = (__kWidth - MarginsWidth * 2 - MarginsCloseWidth)/2
private let Start_X:CGFloat  = MarginsWidth
private var Start_Y:CGFloat = 0
private let ButtonWidth:CGFloat  = 64
private let ButtonHeight:CGFloat  = 64
private let IconWidth:CGFloat  = 18
private let IconHeight:CGFloat  = 18

private let StationViewInnerImageViewTop_Width_Space:CGFloat = 20
private let StationViewInnerLabelTop_Width_Space:CGFloat = 12

private let CollectionCellHeight:CGFloat = ViewHeight

@objc protocol StationViewDelegate{
    func addStationButtonTap(_ sender:UIButton)
    func stationViewTapAction(_ sender:MyStationTapGestureRecognizer)
    func stationViewSwipeAction()
}

class MyStationView: UIView {
    var stationArray:Array<CloadLoginUserRemotModel>?{
        didSet{
           self.reloadData()
        }
    }
    weak var delegate: StationViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(myStationLabel)
        self.backgroundColor = UIColor.white
        getDataSource()
        setStationsView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func stationViewTap(_ gesture:MyStationTapGestureRecognizer){
        if let delegateOK = self.delegate{
            delegateOK.stationViewTapAction(gesture)
        }
    }
    
    
    @objc func addButtonClick(_ sender:UIButton) {
        if let delegateOK = self.delegate{
            delegateOK.addStationButtonTap(sender)
        }
    }
    
    @objc func detailButtonClick(_ sender:UIButton){
       
    }
    
    @objc func swipeGestureAction(_ sender:UISwipeGestureRecognizer){
        if sender.direction == UISwipeGestureRecognizerDirection.down {
            print("Swipe Down")
            if let delegateOK = self.delegate{
                delegateOK.stationViewSwipeAction()
            }
        }
    }
    
    func getDataSource() {
//        let stationModel1 = StationModel.init()
//        stationModel1.state = "normal"
//        stationModel1.name = "WISNUC Station1"
//
//        let stationModel2 = StationModel.init()
//        stationModel2.state = "local"
//        stationModel2.name = "WISNUC Station2"
//
//        let stationModel3 = StationModel.init()
//        stationModel3.state = "offline"
//        stationModel3.name = "自定义设备"
//
//        let stationModel4 = StationModel.init()
//        stationModel4.state = "checking"
//        stationModel4.name = "设备666"
//
//        let stationModel5 = StationModel.init()
//        stationModel5.state = "disk_error"
//        stationModel5.name = "设备7"
        stationArray = []
//        stationArray?.append(stationModel1)
//        stationArray?.append(stationModel2)
//        stationArray?.append(stationModel3)
//        stationArray?.append(stationModel4)
//        stationArray?.append(stationModel5)
    }
    
    func setStationsView() {

        let page = (stationArray?.count)!/2 + 1
        stationScrollView.contentSize = CGSize(width: self.width, height: CGFloat(page*Int(ViewHeight + Width_Space)))
        self.addSubview(stationScrollView)
        setDetailStationsView()
        setAddButtonView()
        let swipeGesture = UISwipeGestureRecognizer.init(target: self, action: #selector(swipeGestureAction(_ :)))
        swipeGesture.direction = .down
        self.addGestureRecognizer(swipeGesture)
    }
    
    func addStation(model:CloadLoginUserRemotModel){
       stationArray?.append(model)
       stationScrollView.removeAllSubviews()
       setStationsView()
    }
    
    func reloadData() {
        stationScrollView.removeAllSubviews()
        setStationsView()
    }

    func setDetailStationsView(){
        var index:Int = 0
        var page:Int = 0
        for (idx,value) in (stationArray?.enumerated())! {
            index = idx % 2
            page = idx/2
            Start_Y =  MarginsCloseWidth
            let view = UIView.init(frame: CGRect(x: CGFloat(index) * (ViewWidth + Width_Space) + Start_X, y: CGFloat(page) * (ViewHeight + Height_Space) + Start_Y, width: ViewWidth, height: ViewHeight))
            view.backgroundColor = UIColor.clear
            view.tag = idx
            view.isUserInteractionEnabled = true
            
            let model:CloadLoginUserRemotModel = value
            let tapGesture = MyStationTapGestureRecognizer.init(target: self, action: #selector(stationViewTap(_ :)))
            tapGesture.stationButtonType = model.state.map { StationButtonType(rawValue: $0) }!
            tapGesture.stationName = model.name
            view.addGestureRecognizer(tapGesture)
            
            let button = detailButton(buttonType:StationButtonType(rawValue: model.state!)!)
            view.addSubview(detailIconView(type: StationButtonType(rawValue: model.state!)!, center: CGPoint(x:button.right , y: button.top)))
            view.addSubview(button)
            button.tag = idx
            let functionLabel = functionOrStationNameLabel(text: model.name!, top: button.frame.maxY + StationViewInnerLabelTop_Width_Space)
            view.addSubview(functionLabel)
            
            let describeLabel = functionOrStationNameLabel(text: describeString(type: StationButtonType(rawValue: model.state!)!), top: functionLabel.bottom + MarginsCloseWidth)
            describeLabel.font = SmallTitleFont
            describeLabel.textColor = LightGrayColor
            view.addSubview(describeLabel)
            stationScrollView.addSubview(view)
        }
    }
    
    func setAddButtonView() {
        let addButtonIndex = (stationArray?.count)! % 2
        let addButtonPage = (stationArray?.count)! / 2
        
        let view = UIView.init(frame: CGRect(x: CGFloat(addButtonIndex) * (ViewWidth + Width_Space) + Start_X, y: CGFloat(addButtonPage) * (ViewHeight + Height_Space) + Start_Y, width: ViewWidth, height: ViewHeight))
        let addButton = detailButton(buttonType:.addNew)
        view.addSubview(addButton)
        view.addSubview(functionOrStationNameLabel(text: LocalizedString(forKey: "add_Device"), top: addButton.frame.maxY + StationViewInnerLabelTop_Width_Space))
        stationScrollView.addSubview(view)
    }
    
    func functionOrStationNameLabel(text:String,top:CGFloat) -> UILabel {
        let labelText = text
        let labelFont = MiddleTitleFont
        let labelWidth = labelWidthFrom(title: labelText, font: labelFont)
        let labelHeight = labelHeightFrom(title: labelText, font: labelFont)
        let label = UILabel.init(frame: CGRect(x: (ViewWidth - labelWidth)/2, y: top, width:labelWidth , height: labelHeight))
        label.font = labelFont
        label.text = labelText
        label.textAlignment = NSTextAlignment.center
        return label
    }
    
    func detailButton(buttonType:StationButtonType) -> UIButton {
        let buttonIndex = (stationArray?.count)! % 2
        let buttonPage = (stationArray?.count)! / 2
        
        let view = UIView.init(frame: CGRect(x: CGFloat(buttonIndex) * (ViewWidth + Width_Space) + Start_X, y: CGFloat(buttonPage) * (ViewHeight + Height_Space) + Start_Y, width: ViewWidth, height: ViewHeight))
    
        let button = UIButton.init()
        var buttonImageName:String?
        switch buttonType {
        case .addNew:
            buttonImageName = "add_station"
            button.addTarget(self, action: #selector(addButtonClick(_ :)), for: UIControlEvents.touchUpInside)
        default:
            buttonImageName = "device"
            button.isUserInteractionEnabled = false
//            button.addTarget(self, action: #selector(detailButtonClick(_ :)), for: UIControlEvents.touchUpInside)
           break
        }
  
        let buttonImage = UIImage.init(named: buttonImageName!)
        button.frame = CGRect(x: (view.width - (buttonImage?.size.width)!)/2  , y: StationViewInnerImageViewTop_Width_Space, width: ButtonWidth, height: ButtonHeight)
        button.setImage(buttonImage, for: UIControlState.normal)
        return button
    }
    
    func describeString(type:StationButtonType) ->String {
        switch type {
        case .normal:
            return ""
        case .checking:
            return LocalizedString(forKey: "station_checking")
        case .diskError:
            return LocalizedString(forKey: "station_disk_error")
        case .offline:
            return LocalizedString(forKey: "station_offline")
        case .local:
            return LocalizedString(forKey: "station_local")
        default:
            return ""
        }
    }
    
    func detailIconView(type:StationButtonType,center:CGPoint) -> UIImageView {
        let imageView = UIImageView.init(frame: CGRect(x: 0, y:0 , width: IconWidth, height: IconHeight))
        imageView.center = center
        var imageName:String!
        switch type {
        case .normal:
            imageName =  "station_normal.png"
        case .checking:
            imageName =  "station_review.png"
        case .diskError:
            imageName =  "disk_warning.png"
        case .offline:
            imageName =  "offline.png"
        case .local:
            imageName =  "local_area.png"
        default:
            break
        }
        imageView.image = UIImage.init(named: imageName)
        return imageView
    }
    
    lazy var myStationLabel: UILabel = {
        let string = LocalizedString(forKey: "my_station")
        let font = SmallTitleFont
        let lable = UILabel.init(frame: CGRect(x:MarginsWidth , y:20 , width: labelWidthFrom(title: string, font: font), height: labelHeightFrom(title: string, font: font)))
        lable.font = font
        lable.text = string
        lable.textColor = LightGrayColor
        return lable
    }()
    
    
    lazy var stationScrollView: UIScrollView = {
        let scrollView = UIScrollView.init(frame: CGRect(x: 0, y:myStationLabel.bottom + MarginsWidth , width: __kWidth, height: self.height - myStationLabel.bottom - MarginsWidth))
        scrollView.isScrollEnabled = true
        scrollView.delegate = self
//        scrollView.backgroundColor = SkyBlueColor
        return scrollView
    }()

    lazy var stationCollectionViewController: MyStationCollectionViewController = {
        let layout = MDCCollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.zero
        layout.itemSize = CGSize(width: size.width, height:CollectionCellHeight)
        let collectionViewController = MyStationCollectionViewController.init(collectionViewLayout: layout)
        return collectionViewController
    }()
}
//- (void) displayContentController: (UIViewController*) content {
//    [self addChildViewController:content];
//    content.view.frame = [self frameForContentController];
//    [self.view addSubview:self.currentClientView];
//    [content didMoveToParentViewController:self];
//}

extension MyStationView:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {


    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
    }
}



