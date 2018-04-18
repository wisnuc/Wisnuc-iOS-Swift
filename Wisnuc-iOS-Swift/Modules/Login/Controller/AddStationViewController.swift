//
//  AddStationViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/18.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MDCActivityIndicator

private let stateLabelTopMargins:CGFloat = 112/2+20+96/2
private let searchAnimationTopMargins:CGFloat = 240/2

enum StationSearchState:Int {
    case searching = 0
    case end
}

class AddStationViewController: BaseViewController {
    var state:StationSearchState?{
        didSet{
            switch state {
            case .searching?:
                searchingStateAction()
            case .end?:
                searchEndStateAction()
            default:
                break
            }
        }
        willSet{
            
        }
    }
    
    var deviceArray:Array<Any>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = LocalizedString(forKey: "添加设备")
        self.view.backgroundColor = UIColor.white
//        self.automaticallyAdjustsScrollViewInsets = true
        setBeginSearchState()
    }
    
    func setBeginSearchState() {
        state = .searching
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func reSearchClick(_ sender:UIButton){
        state = StationSearchState.searching
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
            self.deviceArray = Array.init()
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
        
    }
    
    func setEndSearchState() {
        if deviceArray?.count==0{
            searchNotFoundAction()
        }else{
            state = .end
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
