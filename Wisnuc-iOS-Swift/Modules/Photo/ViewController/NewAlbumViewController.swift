//
//  NewAlbumViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by liupeng on 2018/9/23.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
enum NewAlbumViewControllerState {
    case normal
    case editing
}

@objc protocol NewAlbumViewControllerDelegate {
    func creatNewAlbumFinish(name:String)
}

class NewAlbumViewController: BaseViewController {
    private let reuseIdentifier = "reuseIdentifierCell"
    private let reuseHeaderIdentifier = "reuseIdentifierHeader"
    private let cellContentSizeWidth = (__kWidth - 4)/2
    private let cellContentSizeHeight = (__kWidth - 4)/2
    lazy var dataSource = Array<WSAsset>.init()
    weak var delegate:NewAlbumViewControllerDelegate?
    var state:NewAlbumViewControllerState?{
        didSet{
            switch state {
            case .normal?:
                nomarlStateAction()
            case .editing?:
                editingStateAction()
            default:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(photoCollectionView)
    

        // Do any additional setup after loading the view.
    }
    
    init(style: NavigationStyle,photos:Array<WSAsset>) {
        super.init(style: style)
        self.dataSource.append(contentsOf: photos)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appBar.headerViewController.headerView.trackingScrollView = photoCollectionView
    }
    
    @objc func finishEditing(_ sender:UIBarButtonItem){
        self.state = .normal
        self.delegate?.creatNewAlbumFinish(name: "旅行")
    }
    
    @objc func addTextBarButtonItemTap(_ sender:UIBarButtonItem){
    
    }
    
    @objc func addNewPhotoBarButtonItemTap(_ sender:UIBarButtonItem){
      
    }
    
    @objc func addLocationBarButtonItemTap(_ sender:UIBarButtonItem){
     
    }
    
    @objc func sortPhotoBarButtonItemTap(_ sender:UIBarButtonItem){
        
    }
    
    func setState(_ state:NewAlbumViewControllerState){
        self.state = state
    }
    
    func editingStateAction(){
        self.style = .select
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "text_right.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(finishEditing(_:)))
        let addNewPhotoBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "add_new_photo_new_album.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addNewPhotoBarButtonItemTap(_:)))
        let addTextBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "add_text_photo_new_album.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addTextBarButtonItemTap(_:)))
        let addLocationBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "location_new_album.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addLocationBarButtonItemTap(_:)))
        let sortPhotoBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "sort_photo_new_album.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(sortPhotoBarButtonItemTap(_:)))
        self.navigationItem.rightBarButtonItems = [sortPhotoBarButtonItem,addLocationBarButtonItem,addTextBarButtonItem,addNewPhotoBarButtonItem]
    }
    
    func nomarlStateAction(){
        self.style = .whiteWithoutShadow
        self.navigationItem.leftBarButtonItem = nil
        
    }
    
    lazy var photoCollectionView: UICollectionView = { [weak self] in
        let collectionViewLayout = UICollectionViewFlowLayout.init()
        //        collectionViewLayout.itemSize
        let collectionView = UICollectionView.init(frame: CGRect(x: 0, y: 0, width: __kWidth, height: __kHeight - TabBarHeight), collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(NewPhotoAlbumCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier)
        collectionView.register(UINib.init(nibName: StringExtension.classNameAsString(targetClass: NewPhotoAlbumCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        return collectionView
    }()


}


extension NewAlbumViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:NewPhotoAlbumCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NewPhotoAlbumCollectionViewCell
        let model = dataSource[indexPath.row]
        cell.imageView.image =  UIImage.init(color: .red)
//        cell.nameLabel.text = model.name
//        cell.countLabel.text = "100"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headView:NewPhotoAlbumCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier, for: indexPath) as! NewPhotoAlbumCollectionReusableView
        
        return headView
    }
    
    
}

extension NewAlbumViewController :UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let asset = dataSource[indexPath.row]
        if asset is NetAsset{
          let  netAsset = asset as! NetAsset
            netAsset.metadata?.w
            netAsset.metadata?.h
        }
//        var size = CGSize(width: <#T##CGFloat#>, height: <#T##CGFloat#>)
        return CGSize(width:cellContentSizeWidth , height: cellContentSizeHeight)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return   UIEdgeInsets.init(top: 8, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section == 1 ? CGSize(width: __kWidth, height: 30 + MarginsWidth) : CGSize.zero
    }
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    //        return CGSize(width: cellContentSize, height: 8 + 14 + 8)
    //    }
    
}
