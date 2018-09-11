//
//  File.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/9/11.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import Foundation


class LoginTransition: NSObject ,UIViewControllerAnimatedTransitioning{
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: .from)
        let fromView = fromVC?.view
        transitionContext.containerView.backgroundColor = COR1
        let toVC = transitionContext.viewController(forKey: .to)
        let toView = toVC?.view
        
        let containerView = transitionContext.containerView
        containerView.addSubview(fromView!)
        containerView.addSubview(toView!)
        
        if toVC?.view != nil && fromVC?.view != nil{
           transitionContext.containerView.insertSubview((toVC?.view)!, belowSubview: (fromVC?.view)!)
        }
        // 转场动画
//        toView?.alpha = 0.2
        UIView.animate(withDuration: 0.1, animations: {
            fromView?.alpha = 0.2
        }, completion: { finished in
            UIView.animate(withDuration: 0.1, animations: {
                toView?.alpha = 1
                
            }, completion: { finished in
                
                // 通知完成转场
                transitionContext.completeTransition(true)
            })
            
        })
        
    }
}
