//
//  BottomSheetDummyStaticViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/19.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import MaterialComponents

private let kReusableIdentifierItem = "itemCellIdentifier"
private let CellHeight:CGFloat = 48
@objc protocol BottomSheetDelegate{
    func bottomSheetTap(_ indexPath:IndexPath)

}

class BottomSheetDummyStaticViewController: UIViewController {
    var dataArray:Array<String> = []
    weak var delegate: BottomSheetDelegate?
    
    init(buttonArray:Array<String>) {
        super.init(nibName: nil, bundle: nil)
        setItem(buttonArray:buttonArray)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(overflowCollectionView)
        ViewTools.automaticallyAdjustsScrollView(scrollView: overflowCollectionView, viewController: self)
    }
    
    func setItem(buttonArray:Array<String>){
        dataArray = buttonArray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.preferredContentSize = CGSize(width: __kWidth, height: CGFloat(Int(CellHeight) * dataArray.count))
    }
    
    lazy var overflowCollectionView: UICollectionView = {
        let size = self.view.frame.size
        let layout = MDCCollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.zero
        layout.itemSize = CGSize(width: size.width, height:CellHeight)
        layout.headerReferenceSize = CGSize(width: 0.1, height: 0.1)
        let collectionView = UICollectionView.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height), collectionViewLayout:layout)
        collectionView.register(BottomSheetCollectionViewCell.self, forCellWithReuseIdentifier: kReusableIdentifierItem)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
}

extension BottomSheetDummyStaticViewController:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:BottomSheetCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: kReusableIdentifierItem, for: indexPath) as! BottomSheetCollectionViewCell
        
        cell.textLabel?.text = dataArray[indexPath.item]
        cell.textLabel?.textColor = LightGrayColor
        cell.textLabel?.font = MiddleTitleFont
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
        }
        if let delegateOK = self.delegate{
            delegateOK.bottomSheetTap(indexPath)
        }
    }
}

extension BottomSheetDummyStaticViewController:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
}
