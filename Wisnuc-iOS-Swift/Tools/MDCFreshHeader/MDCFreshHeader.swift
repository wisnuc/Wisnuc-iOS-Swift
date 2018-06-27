//
//  MDCFreshHeader.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/6/27.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents.MDCActivityIndicator

class MDCFreshHeader: MJRefreshStateHeader {
    struct MDCPalette {
        static let blue: UIColor = UIColor(red: 0.129, green: 0.588, blue: 0.953, alpha: 1.0)
        static let red: UIColor = UIColor(red: 0.957, green: 0.263, blue: 0.212, alpha: 1.0)
        static let green: UIColor = UIColor(red: 0.298, green: 0.686, blue: 0.314, alpha: 1.0)
        static let yellow: UIColor = UIColor(red: 1.0, green: 0.922, blue: 0.231, alpha: 1.0)
    }
    override func prepare() {
        super.prepare()
        self.lastUpdatedTimeLabel.isHidden = true
        self.stateLabel.isHidden = true
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        var  arrowCenterX:CGFloat = self.mj_w * 0.5
        if (!self.stateLabel.isHidden) {
            let stateWidth:CGFloat  = self.stateLabel.mj_textWith()
            var timeWidth:CGFloat = 0.0
            if (!self.lastUpdatedTimeLabel.isHidden) {
                timeWidth = self.lastUpdatedTimeLabel.mj_textWith()
            }
            let textWidth:CGFloat  = max(stateWidth, timeWidth)
            arrowCenterX -= textWidth / 2 + self.labelLeftInset;
        }
        let arrowCenterY:CGFloat  = self.mj_h * 0.5;
        let arrowCenter:CGPoint  = CGPoint(x: arrowCenterX, y: arrowCenterY)
        if self.loadingView.constraints.count == 0 {
            self.loadingView.center = arrowCenter
        }
    }
    
    lazy var loadingView: MDCActivityIndicator = {
        
        let activity = MDCActivityIndicator.init(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        activity.cycleColors = [MDCPalette.blue, MDCPalette.red, MDCPalette.green, MDCPalette.yellow]
        activity.radius = 12.0
        activity.strokeWidth = 2.0
        activity.indicatorMode = .indeterminate
//        activity.sizeToFit()
        self.addSubview(activity)
        return activity
    }()
    
    
    override var state: MJRefreshState{
        didSet{
//            let oldState = self.state
//            if state == oldState {return}
//            super.state = state
            if state == MJRefreshState.idle{
//                if oldState == MJRefreshState.refreshing {
//                    UIView.animate(withDuration: TimeInterval(MJRefreshSlowAnimationDuration), animations: {
//                        self.loadingView.alpha = 0.0
//                    }) { (finished) in
//                        // 如果执行完动画发现不是idle状态，就直接返回，进入其他状态
//                        if (self.state != MJRefreshState.idle) {return}
//                        self.loadingView.alpha = 1.0
//                        self.loadingView.stopAnimating()
//                    }
//                } else {
                    self.loadingView.stopAnimating()
//                }
            } else if state == MJRefreshState.pulling{
                self.loadingView.stopAnimating()
            } else if (state == MJRefreshState.refreshing) {
                self.loadingView.alpha = 1.0  // 防止refreshing -> idle的动画完毕动作没有被执行
                self.loadingView.startAnimating()
            }
        }
    }
}
