//
//  AddStationViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/18.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents

private let stateLabelTopMargins:CGFloat = 112/2+20+96/2
private let searchAnimationTopMargins:CGFloat = 240/2

private let ViewWidth:CGFloat  = 234
private let ViewHeight:CGFloat  = 234
private let Start_X:CGFloat  = (__kWidth - ViewWidth)/2
private let Start_Y:CGFloat  = 0
private let Width_Space:CGFloat  = Start_X * 2


enum StationSearchState:Int {
    case searching = 0
    case end
    case notFound
    case abort
}

class AddStationViewController: BaseViewController {
    var state:StationSearchState?{
        didSet{
            switch state {
            case .searching?:
                searchingStateAction()
            case .end?:
                searchEndStateAction()
            case .notFound?:
                searchNotFoundAction()
            case .abort?:
                searchAbortAction()
            default:
                break
            }
        }
        willSet{
            
        }
    }
    
    var deviceArray:Array<FoundStationModel>?
    var currentIndex:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
        setBasicStyle()
        setBeginSearchState()
    }
    
    func setData(){
        deviceArray = Array.init()
        let model1 = FoundStationModel()
        model1.type = DeviceForSearchState.applyToUse.rawValue
        model1.name = "My Station"
        
        let model2 = FoundStationModel()
        model2.type = DeviceForSearchState.initialization.rawValue
        model2.name = "袅袅炊烟"
        
        let model3 = FoundStationModel()
        model3.type = DeviceForSearchState.importTo.rawValue
        model3.name = "闻上盒子"
        deviceArray?.append(model1)
        deviceArray?.append(model2)
        deviceArray?.append(model3)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        state = .end
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reSearchClick(_ sender:UIButton){
        state = StationSearchState.searching
    }
    
    @objc func rightBarButtonItemClick(_ sender:UIBarButtonItem){
        let bottomSheetVC = BottomSheetDummyStaticViewController.init()
        let bottomSheet = MDCBottomSheetController.init(contentViewController: bottomSheetVC)
        self.present(bottomSheet, animated: true, completion: nil)
    }
    
    // MARK: - User events
    
    @objc func didChangePage(_ sender: MDCPageControl) {
        var offset = self.deviceBrowserScrollView.contentOffset
        offset.x = CGFloat(sender.currentPage) * self.deviceBrowserScrollView.bounds.size.width
        self.deviceBrowserScrollView.setContentOffset(offset, animated: true)
    }
    
    @objc func nextStepForSearchEndButtonClick(_ sender:MDBaseButton){
        let model = deviceArray![sender.tag]
        switch model.type {
        case DeviceForSearchState.initialization.rawValue:
            let initDiskVC = InitializationDiskViewController.init()
            self.navigationController?.pushViewController(initDiskVC, animated: true)
        default:
            break
        }
    }
    
    func setBeginSearchState() {
        state = .searching
    }
    
    func setBasicStyle(){
        self.title = LocalizedString(forKey: "添加设备")
        self.view.backgroundColor = UIColor.white
        let rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "more.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightBarButtonItemClick(_ :)))
        appBar.navigationBar.rightBarButtonItem = rightBarButtonItem
        if #available(iOS 11.0, *) {
            self.view.insetsLayoutMarginsFromSafeArea = true
        } else {
            // Fallback on earlier versions
        }
        //        self.automaticallyAdjustsScrollViewInsets = true
    }
    
    func searchingStateAction() {
        stateLabel.removeFromSuperview()
        searchingAnimationView.removeFromSuperview()
        reSearchButton.removeFromSuperview()
        stateLabel.text = LocalizedString(forKey: "station_searching")
        self.view.addSubview(stateLabel)
        self.view.addSubview(searchingAnimationView)
        startSearchingAnimation()
        analogueTerminal()
    }
    
    func analogueTerminal() {
        DispatchQueue.global(qos:.default).asyncAfter(deadline: DispatchTime.now() + 4) {
            DispatchQueue.main.async {
                self.setEndSearchState()
            }
        }
    }
    
    func startSearchingAnimation() {
        searchingAnimationView.startAnimating()
    }
    
    func stopSearchingAnimation() {
        searchingAnimationView.stopAnimating()
    }
    
    func searchNotFoundAction(){
        stopSearchingAnimation()
        stateLabel.removeFromSuperview()
        searchingAnimationView.removeFromSuperview()
        reSearchButton.removeFromSuperview()
        stateLabel.text = LocalizedString(forKey: "station_not_found")
        self.view.addSubview(stateLabel)
        self.view.addSubview(reSearchButton)
    }
    
    func searchEndStateAction(){
        searchingAnimationView.removeFromSuperview()
        reSearchButton.removeFromSuperview()
        setScrollViewContent()
    }
    
    func setScrollViewContent(){
        self.view.addSubview(deviceBrowserScrollView)
        self.view.addSubview(deviceBrowserPageControl)
        self.view.addSubview(nextStepForSearchEndButton)
        self.deviceBrowserScrollView.contentSize = CGSize(width: __kWidth*CGFloat((deviceArray?.count)!), height: deviceBrowserScrollView.height)
        self.deviceBrowserPageControl.numberOfPages = (deviceArray?.count)!
        for(idx,_) in (deviceArray?.enumerated())!{
            let circleView = UIView.init(frame: CGRect(x: CGFloat(idx) * (ViewWidth + Width_Space) + Start_X , y: Start_Y, width: ViewWidth, height: ViewHeight))
            circleView.layer.masksToBounds = true
            circleView.layer.borderWidth = 8
            circleView.layer.borderColor = WhiteGrayColor.cgColor
            circleView.layer.cornerRadius = circleView.width/2
            circleView.layer.contents = UIImage.init(named: "station_w215i.png")?.cgImage;
            self.deviceBrowserScrollView.addSubview(circleView)
            
//            let stationImage = UIImage.init(named: "station_w215i.png")
//            let imageView = UIImageView.init(image: stationImage)
//            imageView.frame = CGRect(x: 0, y: 0, width: (stationImage?.size.width)!, height: (stationImage?.size.height)!)
//            imageView.center = circleView.center
//            circleView.addSubview(imageView)
        }
        let model = deviceArray?.first
        let titleString = nextButtonString(state: DeviceForSearchState(rawValue: (model?.type)!)!)
        nextStepForSearchEndButton.setTitle(titleString, for: UIControlState.normal)
        stateLabel.text = model?.name
        self.nextStepForSearchEndButton.tag = currentIndex
    }
    
    func searchAbortAction(){
        
    }
    
    func setEndSearchState() {
        if deviceArray?.count==0{
            state = .notFound
        }else{
            state = .end
        }
        
    }
    
    func nextButtonString(state:DeviceForSearchState) ->String {
        switch state {
        case .applyToUse:
            return LocalizedString(forKey: "station_apply_to_use")
        case .initialization:
            return LocalizedString(forKey: "station_init_next")
        case .importTo:
            return LocalizedString(forKey: "station_improt")
//        default:
//            return ""
//           break
        }
    }
    
    lazy var reSearchButton: UIButton = {
        let button = UIButton.init(frame: searchingAnimationView.frame)
        button.setImage(UIImage.init(named: "refresh.png"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(reSearchClick(_ :)), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    lazy var searchingAnimationView:MDCActivityIndicator = {
        let width: CGFloat = __kWidth / 2
        let height: CGFloat = __kHeight / 2
        
        //Initialize single color progress indicator
        let frame: CGRect = CGRect(x: width - 48/2, y: stateLabel.bottom + searchAnimationTopMargins, width: 48, height: 48)
        let activityIndicator = MDCActivityIndicator(frame: CGRect.zero)
        activityIndicator.frame = frame
        // Pass colors you want to indicator to cycle through
        activityIndicator.cycleColors = [UIColor.blue, UIColor.red, UIColor.green, UIColor.yellow]
        activityIndicator.radius = 18.0
        activityIndicator.strokeWidth = 3.5
        activityIndicator.indicatorMode = .indeterminate
        activityIndicator.sizeToFit()
        return activityIndicator
    }()
    
    lazy var stateLabel: UILabel = {
        let label = UILabel.init()
        let text = LocalizedString(forKey: "设备搜索中")
        label.text = text
        let font = BigTitleFont
        label.font = font
        label.textColor = DarkGrayColor
        let height = labelWidthFrom(title: label.text!, font: font)
        let width = self.view.width
        label.frame = CGRect(x: 0, y: stateLabelTopMargins, width: width, height: height )
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    lazy var deviceBrowserScrollView: UIScrollView = {
        let scrollView = UIScrollView.init(frame: CGRect(x: 0, y: stateLabel.bottom + MarginsWidth, width: __kWidth, height:deviceBrowserPageControl.bottom - stateLabel.bottom))
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.bounces = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    lazy var deviceBrowserPageControl:MDCPageControl = {
        let pageControl = MDCPageControl.init(frame: CGRect(x: 0, y: stateLabel.bottom + 259 + 43 , width: __kWidth, height: 16))
        pageControl.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        pageControl.addTarget(self, action: #selector(didChangePage), for: .valueChanged)
        pageControl.pageIndicatorTintColor = WhiteGrayColor
        pageControl.hidesForSinglePage = true
        pageControl.currentPageIndicatorTintColor = COR1
        return pageControl
    }()
    
    lazy var nextStepForSearchEndButton: MDBaseButton = {
        let button = MDBaseButton.init(frame: CGRect(x: MarginsWidth, y: __kHeight - CommonButtonHeight - MarginsBottomHeight, width: __kWidth - MarginsWidth*2, height: CommonButtonHeight))
        
        button.backgroundColor = COR1
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        button.addTarget(self, action: #selector(nextStepForSearchEndButtonClick(_ :)), for: UIControlEvents.touchUpInside)
    
        return button
    }()
}

extension AddStationViewController:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        // 随着滑动改变pageControl的状态
        let index = Int(offset.x / view.bounds.width)
//        deviceBrowserPageControl.currentPage = index
        deviceBrowserPageControl.scrollViewDidScroll(scrollView)
        currentIndex = index
        let model = deviceArray![index]
        self.stateLabel.text = model.name
        let buttonTitle = nextButtonString(state: DeviceForSearchState(rawValue: model.type!)!)
        self.nextStepForSearchEndButton.setTitle(buttonTitle, for: UIControlState.normal)
        self.nextStepForSearchEndButton.tag = index
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        deviceBrowserPageControl.scrollViewDidEndDecelerating(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        deviceBrowserPageControl.scrollViewDidEndScrollingAnimation(scrollView)
    }

}
