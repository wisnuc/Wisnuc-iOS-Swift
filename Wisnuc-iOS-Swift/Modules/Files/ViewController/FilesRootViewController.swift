//
//  FilesRootViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/5/3.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents
let colors = [ "red", "blue", "green", "black", "yellow", "purple" ]
private let reusableIdentifierItem = "itemCellIdentifier"
private let cellFolderHeight:CGFloat = 48
private let cellWidth:CGFloat = (__kWidth - 4)/2
private let cellHeight:CGFloat = 137

class FilesRootViewController: BaseViewController {
    var fhvc:MDCFlexibleHeaderViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.fhvc = MDCFlexibleHeaderViewController.init(nibName: nil, bundle: nil)
//        self.addChildViewController(self.fhvc)
//        self.minimumHeaderHeight = 0;
        
        self.addChildViewController(collcectionViewController)
        collcectionViewController.didMove(toParentViewController: self)
        collcectionViewController.view.frame =  CGRect.init(x: self.view.left, y: self.view.top + searchBar.bottom + MarginsCloseWidth/2, width: self.view.width, height: self.view.height - MDCAppNavigationBarHeight)
        self.view.addSubview(collcectionViewController.view)
//        self.appBar.headerViewController.headerView.delegate = self
//         self.appBar.headerViewController.headerView.minMaxHeightIncludesSafeArea = false
//        self.appBar.headerViewController.headerView.tintColor = UIColor.clear
//        self.appBar.headerViewController.headerView.shiftBehavior = MDCFlexibleHeaderShiftBehavior.enabled
        self.view.addSubview(searchBar)
        self.view.backgroundColor = lightGrayBackgroudColor
//        self.view.sendSubview(toBack: collcectionViewController.view)
//       self.appBar.headerViewController.headerView.addSubview(searchBar)
        
//       self.appBar.headerViewController.headerView.trackingScrollView = self.collcectionViewController.collectionView
//       self.xx_fixNavBarPenetrable()
         self.appBar.headerViewController.headerView.isHidden = true
        
        self.collcectionViewController.collectionView?.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions(rawValue: NSKeyValueObservingOptions.RawValue(UInt8(NSKeyValueObservingOptions.old.rawValue) | UInt8(NSKeyValueObservingOptions.new.rawValue))), context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as AnyObject? === self.collcectionViewController.collectionView && keyPath == "contentOffset" {
            let newY:CGFloat = change![NSKeyValueChange.init(rawValue: <#T##UInt#>)].y
//            CGFloat newY = [change[@"new"] CGPointValue].y;
//            CGFloat oldY = [change[@"old"] CGPointValue].y;
//            float i = newY - oldY;       //i>0上滑， i<0下滑
//            if (self.tableView.contentOffset.y>-64&&self.tableView.contentOffset.y<=24) {//边界条件，此处不精确
//                if (i<=0&&_isHidding == NO&&self.navigationController.navigationBar.frame.origin.y==20) {    //下拉＋bar 已经显示的状态，不再移动
//                    return;
//                }
//                _isHidding = NO;
//                self.navigationController.navigationBar.frame = CGRectMake(0, -44-self.tableView.contentOffset.y, 320, 44);
//            }else if (self.tableView.contentOffset.y > 24) {
//
//                if (i>10) {//更改数值大小可以控制触发 navigation bar 的滑动速度
//                    _isHidding = YES;
//                }else if(i<-10) {
//                    _isHidding = NO;
//                }else {
//
//                }
//            }
//            [self.navigationController setNavigationBarHidden:_isHidding animated:YES];
        }
    }
    
    lazy var collcectionViewController : MDCCollectionViewController = {
        let layout = MDCCollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets.zero
//        layout.itemSize = CGSize(width: size.width, height:CellHeight)
        let collectVC = FilesRootCollectionViewController.init(collectionViewLayout: layout)
        collectVC.collectionView?.isScrollEnabled = true
        collectVC.delegate = self
        return collectVC
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar.init(frame: CGRect(x: MarginsCloseWidth, y: 20, width: __kWidth - MarginsCloseWidth * 2, height: cellFolderHeight))
        return searchBar
    }()
}


extension FilesRootViewController:FilesRootCollectionViewControllerDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.appBar.headerViewController.headerView.trackingScrollView {
            self.appBar.headerViewController.headerView.trackingScrollDidScroll()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.appBar.headerViewController.headerView.trackingScrollView {
            self.appBar.headerViewController.headerView.trackingScrollDidEndDecelerating()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let headerView = self.appBar.headerViewController.headerView
        if scrollView == headerView.trackingScrollView {
            headerView.trackingScrollDidEndDraggingWillDecelerate(decelerate)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let headerView = self.appBar.headerViewController.headerView
        if scrollView == headerView.trackingScrollView {
            headerView.trackingScrollWillEndDragging(withVelocity: velocity, targetContentOffset: targetContentOffset)
        }
    }
}


extension FilesRootViewController:MDCFlexibleHeaderViewDelegate{
    func flexibleHeaderViewNeedsStatusBarAppearanceUpdate(_ headerView: MDCFlexibleHeaderView) {
        
    }
    
    func flexibleHeaderViewFrameDidChange(_ headerView: MDCFlexibleHeaderView) {
//        var headerContentAlpha:CGFloat = 0
//        switch (headerView.scrollPhase) {
//        case MDCFlexibleHeaderScrollPhase.collapsing: break
//        case MDCFlexibleHeaderScrollPhase.overExtending:
//            headerContentAlpha = 1
//        case MDCFlexibleHeaderScrollPhase.shifting:
//            headerContentAlpha = 1 - headerView.scrollPhasePercentage;
//        }
//
//        for subview  in self.appBar.headerViewController.headerView.subviews {
//            subview.alpha = headerContentAlpha
//        }
    }
}


//extension FilesRootViewController:UICollectionViewDelegate{
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 2
//    }
//
//}
//
//extension FilesRootViewController:UICollectionViewDataSource{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 5
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        switch indexPath.section {
//        case 0:
//            let cell:MDCCollectionViewTextCell = collectionView.dequeueReusableCell(withReuseIdentifier: reusableIdentifierItem,
//                                                                                    for: indexPath) as! MDCCollectionViewTextCell
//            if let cell = cell as? MDCCollectionViewTextCell {
//                cell.textLabel?.text = colors[indexPath.item]
//            }
//            return cell
//        case 1:
//            let cell:MDCCollectionViewTextCell = collectionView.dequeueReusableCell(withReuseIdentifier: reusableIdentifierItem, for: indexPath) as! MDCCollectionViewTextCell
//            return cell
//        default:
//             let cell:MDCCollectionViewTextCell = collectionView.dequeueReusableCell(withReuseIdentifier: reusableIdentifierItem, for: indexPath) as! MDCCollectionViewTextCell
//            return cell
//        }
//    }
//}
//
//extension FilesRootViewController:UICollectionViewDelegateFlowLayout{
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if indexPath.section == 0{
//            return CGSize(width: cellWidth, height: cellFolderHeight)
//        }else{
//            return CGSize(width: cellWidth, height: cellHeight)
//        }
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 4
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 4
//    }
//}



