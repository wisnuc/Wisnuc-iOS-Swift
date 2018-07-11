//
//  WSShowBigimgViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/7/11.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit

@objc protocol WSShowBigImgViewControllerDelegate {
//    - (void)photoBrowser:(JYShowBigImgViewController *)browser scrollToIndexPath:(NSIndexPath *)indexPath;
//
//    - (UIView *)photoBrowser:(JYShowBigImgViewController *)browser willDismissAtIndexPath:(NSIndexPath *)indexPath;
}

class WSShowBigimgViewController: UIViewController {
    weak var delegate:WSShowBigImgViewControllerDelegate?
    var indexBeforeRotation:Int = 0
    var selectIndex:Int = 0
    var models:Array<WSAsset>?
    var scaleImage:UIImage?
    var senderViewForAnimation:UIView?
    private let cellReuseIdentifier = "WSBigimgCollectionViewCell"
    init() {
        super.init(nibName: nil, bundle: nil)
        if self.responds(to: #selector(getter: self.automaticallyAdjustsScrollViewInsets) ){
            self.automaticallyAdjustsScrollViewInsets = false
            self.modalPresentationStyle = UIModalPresentationStyle.custom
            self.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.modalPresentationCapturesStatusBarAppearance = true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetting()
        self.view.addSubview(self.collectionView)
//        [self initNavBtns];
    }
    
    func basicSetting(){
        self.view.backgroundColor = UIColor.black
        ViewTools.automaticallyAdjustsScrollView(scrollView: collectionView, viewController: self)
        self.view.clipsToBounds = true
        self.view.alpha = 0
    }
    
    func gestureSetting(){
        self.view.addGestureRecognizer(panGesture)
        let longGesture = UILongPressGestureRecognizer.init(target: self, action:#selector(longGestureRecognized(_ :)))
        self.view.addGestureRecognizer(longGesture)
    }
    
    @objc func panGestureRecognized(_ gesture:UIPanGestureRecognizer){
        
    }
    
    @objc func longGestureRecognized(_ sender:UILongPressGestureRecognizer){
        if (sender.state == UIGestureRecognizerState.began) {
           
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var collectionViewlayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        layout.minimumLineSpacing = CGFloat(kItemMargin);
        layout.sectionInset = UIEdgeInsetsMake(0, CGFloat(kItemMargin/2), 0, CGFloat(kItemMargin/2));
        layout.itemSize = self.view.bounds.size;
        return layout
    }()

    lazy var collectionView: UICollectionView = {
        let collection = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: collectionViewlayout)
        collection.register(WSBigimgCollectionViewCell.self, forCellWithReuseIdentifier:cellReuseIdentifier)
        
        collection.dataSource = self
        collection.delegate = self
        collection.isPagingEnabled = true
        collection.backgroundColor = UIColor.clear
        
        collection.setCollectionViewLayout(collectionViewlayout, animated: true)
        collection.frame = CGRect(x: -CGFloat(kItemMargin)/2, y: 0, width: __kWidth+CGFloat(kItemMargin), height: __kHeight)
//        // TODO: rotation
        collection.setContentOffset(CGPoint(x: __kWidth + CGFloat(kItemMargin)*CGFloat(indexBeforeRotation), y: 0), animated: false)
        return collection
    }()
    
    lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(panGestureRecognized(_ :)))
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        return gesture
    }()

}

extension WSShowBigimgViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:WSBigimgCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! WSBigimgCollectionViewCell
        return cell
    }
}
