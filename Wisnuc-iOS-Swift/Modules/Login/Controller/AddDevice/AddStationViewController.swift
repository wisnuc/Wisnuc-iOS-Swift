//
//  AddStationViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/18.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents

private let stateLabelTopMargins:CGFloat = MDCAppNavigationBarHeight+96/2
private let searchAnimationTopMargins:CGFloat = 240/2

private let ViewWidth:CGFloat  = 234
private let ViewHeight:CGFloat  = 234
private let Start_X:CGFloat  = (__kWidth - ViewWidth)/2
private let Start_Y:CGFloat  = stateLabelTopMargins
private let Width_Space:CGFloat  = Start_X * 2

enum StationSearchState:Int {
    case searching = 0
    case end
    case notFound
    case abort
}

@objc protocol AddStationDelegate {
    func addStationFinish(model:Any)
}

class AddStationViewController: BaseViewController {
    weak var delegate:AddStationDelegate?
//    var userDataSouce:Arra?
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
    
    var deviceArray:Array<CloadLoginUserRemotModel>?{
        didSet{
            
        }
    }
    var currentIndex:Int = 0
    var rightButtonArray:Array<String> = []
    var bottomSheet:BottomSheetDummyStaticViewController?
    var popupController:CNPPopupController?
    var serverBrower:NetServerBrower?
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
        setBasicStyle()
        setBeginSearchState()
    }
    
    func setData(){
        deviceArray = Array.init()
//        let model1 = StationModel()
//        model1.type = DeviceForSearchState.applyToUse.rawValue
//        model1.name = "My Station"
//        model1.adress = "111.222.222.111"
//        model1.state = StationButtonType.normal.rawValue
//
//        let model2 = StationModel()
//        model2.type = DeviceForSearchState.initialization.rawValue
//        model2.name = "袅袅炊烟"
//        model2.state = StationButtonType.normal.rawValue
//
//        let model3 = StationModel()
//        model3.type = DeviceForSearchState.importTo.rawValue
//        model3.name = "闻上盒子"
//        model3.adress = "133.222.222.111"
//        model3.state = StationButtonType.normal.rawValue
//        deviceArray?.append(model1)
//        deviceArray?.append(model2)
//        deviceArray?.append(model3)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        state = .end
        serverBrower = nil
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
    
    @objc func rightBarButtonItemClick(_ sender:UIBarButtonItem?){
        let array = rightButtonArray
        let bottomSheetVC = BottomSheetDummyStaticViewController.init(buttonArray: array)
        bottomSheetVC.delegate = self
        let bottomSheet = MDCBottomSheetController.init(contentViewController: bottomSheetVC)
        self.bottomSheet = bottomSheetVC
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
            
         case DeviceForSearchState.applyToUse.rawValue:
           ActivityIndicator.startActivityIndicatorAnimation()
            DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 2.3) {
                self.searchUser(model.LANIP!, closure: { [weak self] (error, userModel) in
                    if error == nil{
                        if userModel?.username == "13165786562"{
                            dispatch_async_on_main_queue {
                                ActivityIndicator.stopActivityIndicatorAnimation()
                                self?.navigationController?.popViewController(animated: true)
                                if let delegateOK = self?.delegate{
                                    model.username = userModel?.username
                                    model.uuid = userModel?.uuid
                                    delegateOK.addStationFinish(model: model)
                                    Message.message(text: LocalizedString(forKey: "添加成功"))
                                }
                            }
                        }else{
                            ActivityIndicator.stopActivityIndicatorAnimation()
                        }
                    }else{
                        ActivityIndicator.stopActivityIndicatorAnimation()
                        Message.message(text: LocalizedString(forKey: "添加失败->\(String(describing: (error?.localizedDescription)!))"))
                    }
                })
            }
            
        case DeviceForSearchState.importTo.rawValue:
            Message.message(text: LocalizedString(forKey: "添加成功"))
            DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now() + 2.3) {
                dispatch_async_on_main_queue {
                    self.navigationController?.popViewController(animated: true)
                    if let delegateOK = self.delegate{
                        delegateOK.addStationFinish(model: model)
                    }
                }
            }
           
        default:
            break
        }
    }
    
    @objc func circleViewTap(_ sender:UIGestureRecognizer){

        let view = sender.view
        let model = deviceArray![(view?.tag)!]
        switch model.type {
        case DeviceForSearchState.applyToUse.rawValue:
            let diskModel1 = DiskModel.init()
            diskModel1.name = "666"
            diskModel1.admin = "Mark"
            diskModel1.capacity = 10.0
            diskModel1.effectiveCapacity = 5.23
            
            let diskArray = [diskModel1]
            DiskPopUpViewManager.sharedInstance.showPopupWithStyle(DeviceForSearchState(rawValue: model.type!)!, CNPPopupStyle.centered, diskArray:diskArray , stationModel: model)
        case DeviceForSearchState.initialization.rawValue:
            break
        case DeviceForSearchState.importTo.rawValue:
            let diskModel1 = DiskModel.init()
            diskModel1.name = "666"
            diskModel1.admin = "Mark"
            diskModel1.capacity = 10.0
            diskModel1.effectiveCapacity = 5.23
            diskModel1.type = "Single"
            
            let diskModel2 = DiskModel.init()
            diskModel2.name = "777"
            diskModel2.admin = "An"
            diskModel2.capacity = 5.0
            diskModel2.effectiveCapacity = 2.20
            diskModel2.type = "RAID1"
            
            let diskArray = [diskModel1,diskModel2]
            DiskPopUpViewManager.sharedInstance.showPopupWithStyle(DeviceForSearchState(rawValue: model.type!)!, CNPPopupStyle.centered, diskArray:diskArray , stationModel: model)
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
     
    }
    

    func startSearchingAnimation() {
        searchingAnimationView.startAnimating()
    }
    
    func stopSearchingAnimation() {
        searchingAnimationView.stopAnimating()
    }
    
    func removeAllSuperView(){
       ViewTools.removeAllSuperView(view: self.deviceBrowserScrollView)
       ViewTools.removeAllSuperViewExceptNavigationBar(view: self.view)
    }
    
    func bottomSheetStateExchange(){
        if bottomSheet != nil && (bottomSheet?.isViewLoaded)! {
            bottomSheet?.dismiss(animated: true, completion: {
                
                self.rightBarButtonItemClick(Optional.none)
            })
        }
    }
    
    func searchingStateAction() {
        rightButtonArray = [LocalizedString(forKey: "手动添加"),LocalizedString(forKey: "通过IP地址添加")]
        removeAllSuperView()
        stateLabel.text = LocalizedString(forKey: "station_searching")
        self.view.addSubview(stateLabel)
        self.view.addSubview(searchingAnimationView)
        bottomSheetStateExchange()
        startSearchingAnimation()
        if serverBrower != nil{
            serverBrower = nil
        }
        serverBrower = NetServerBrower.init(type: kHTTPTCPSearchBrowerType, port: -1)
        serverBrower?.delegate = self
        deviceArray?.removeAll()
    }
    
    func searchNotFoundAction(){
        rightButtonArray = [LocalizedString(forKey: "刷新"),LocalizedString(forKey: "手动添加"),LocalizedString(forKey: "通过IP地址添加")]
        stopSearchingAnimation()
        removeAllSuperView()
        stateLabel.text = LocalizedString(forKey: "station_not_found")
        self.view.addSubview(stateLabel)
        self.view.addSubview(reSearchButton)
        bottomSheetStateExchange()
    }

    func searchEndStateAction(){
        rightButtonArray = [LocalizedString(forKey: "刷新"),LocalizedString(forKey: "手动添加"),LocalizedString(forKey: "通过IP地址添加")]
        removeAllSuperView()
        setScrollViewContent()
        bottomSheetStateExchange()
    }
    
    func setScrollViewContent(){
        self.view.addSubview(deviceBrowserScrollView)
        self.view.addSubview(deviceBrowserPageControl)
        self.view.addSubview(nextStepForSearchEndButton)
        self.deviceBrowserScrollView.contentSize = CGSize(width: __kWidth*CGFloat((deviceArray?.count)!), height: deviceBrowserScrollView.height)
        self.deviceBrowserPageControl.numberOfPages = (deviceArray?.count)!
        for(idx,value) in (deviceArray?.enumerated())!{
            let circleView = UIView.init(frame: CGRect(x: CGFloat(idx) * (ViewWidth + Width_Space) + Start_X , y: Start_Y, width: ViewWidth, height: ViewHeight))
            circleView.layer.masksToBounds = true
            circleView.layer.borderWidth = 8
            circleView.layer.borderColor = WhiteGrayColor.cgColor
            circleView.layer.cornerRadius = circleView.width/2
            circleView.layer.contents = UIImage.init(named: "station_w215i.png")?.cgImage;
            circleView.isUserInteractionEnabled = true
            let tapGestrue = UITapGestureRecognizer.init()
            tapGestrue.addTarget(self, action: #selector(circleViewTap(_:)))
            circleView.addGestureRecognizer(tapGestrue)
            circleView.tag = idx
            self.deviceBrowserScrollView.addSubview(circleView)
            
//            let stationImage = UIImage.init(named: "station_w215i.png")
//            let imageView = UIImageView.init(image: stationImage)
//            imageView.frame = CGRect(x: 0, y: 0, width: (stationImage?.size.width)!, height: (stationImage?.size.height)!)
//            imageView.center = circleView.center
//            circleView.addSubview(imageView)
            let model = value
            let font = stateLabel.font
            let height = labelHeightFrom(title: model.name!, font: font!)
            let width = self.view.width
            let label = UILabel.init(frame: CGRect(x: CGFloat(idx) * (width + 0) + 0, y: circleView.top - MarginsSoFarWidth - height-20, width: width, height: height))
            label.font = font
            label.text = value.name!
            label.textColor = stateLabel.textColor!
            label.textAlignment = NSTextAlignment.center
            self.deviceBrowserScrollView.addSubview(label)
        }
        let model = deviceArray?.first
        let titleString = nextButtonString(state: DeviceForSearchState(rawValue: (model?.type)!)!)
        nextStepForSearchEndButton.setTitle(titleString, for: UIControlState.normal)
      
        self.nextStepForSearchEndButton.tag = currentIndex
    }
    
    func searchAbortAction(){
        
    }
    
    func setEndSearchState() {
        if state == .searching{
            if deviceArray?.count==0{
                state = .notFound
            }else{
                state = .end
            }
        }
    }
    
    func presentToIPAddStation(){
        let IPVC = IPAddDeviceViewController.init()
        self.present(IPVC, animated: true) {
            
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
    
    func searchStation(_ server:NetService, _ baseURL:String){
        if Validate.IP(baseURL).isRight {
            let model = CloadLoginUserRemotModel.init()
            model.name = server.name
            model.type = DeviceForSearchState.applyToUse.rawValue
            model.LANIP = baseURL
            if model.global == nil{
                 model.state = StationButtonType.local.rawValue
            }
            self.deviceArray?.append(model)
        }
    }
    
    func searchUser( _ baseURL:String, closure:@escaping (_ error:Error?,_ usermodel:UserModel?)->()){
        let urlString = "http://\(baseURL):3000"
        LocalUserAPI.init(url: urlString).startRequestJSONCompletionHandler { (response) in
            if response.error == nil{
               let rootArray = response.result.value as! NSArray
               for value in rootArray{
                    do {
                        let data = try?JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions.prettyPrinted)
                        let userModel = try JSONDecoder().decode(UserModel.self, from: data!)
                        closure(nil, userModel)
                    } catch {
                        closure(BaseError(localizedDescription: ErrorLocalizedDescription.JsonModel.SwitchTOModelFail, code: ErrorCode.JsonModel.SwitchTOModelFail),nil)
                    }
                }
               
            }else{
                closure(response.error,nil)
            }
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
//        label.backgroundColor = UIColor.red
        return label
    }()
    
    lazy var deviceBrowserScrollView: UIScrollView = {
        let scrollView = UIScrollView.init(frame: CGRect(x: 0, y: stateLabel.top, width: __kWidth, height:deviceBrowserPageControl.top - 10))
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

extension AddStationViewController:BottomSheetDelegate{
    func bottomSheetTap(_ indexPath: IndexPath) {
        if state == .searching{
            switch indexPath.row {
            case 0:
               break
            case 1:
                presentToIPAddStation()
            default:
                break
            }
        }else{
            switch indexPath.row {
            case 0:
                state = StationSearchState.searching
            case 1:break
            case 2:
                presentToIPAddStation()
            default:
                break
            }
        }
        
    }
}

extension AddStationViewController:NetServerBrowerForLogDelegate{
    func serviceDidStop(service: NetService) {
        self.setEndSearchState()
    }
    
    func serverBrowserFoundService(service: NetService) {
        if (service.hostName?.contains(find: "wisnuc"))! || (service.hostName?.contains(find: "phi"))! {
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            for address in service.addresses!{
                address.withUnsafeBytes { (pointer:UnsafePointer<sockaddr>) -> Void in
                    guard getnameinfo(pointer, socklen_t(address.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                        return
                    }
                }
                let ipAddress = String(cString:hostname)
                print(ipAddress)
                searchStation(service, ipAddress)
            }
        }
    }

    func serverBrowserLostService(service: NetService, index: Int) {
      
    }
}


