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

enum HeaderExtensionType {
    case textView
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
    lazy var headerExtensionArray:Array<HeaderExtensionType> =  Array.init()
    weak var delegate:NewAlbumViewControllerDelegate?
    var albumTitleText:String?
    var headView:NewPhotoAlbumCollectionReusableView?
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
        
        

        // Do any additional setup after loading the view.
    }
    
    init(style: NavigationStyle,photos:Array<WSAsset>) {
        super.init(style: style)
        self.dataSource.append(contentsOf: photos)
        self.view.addSubview(photoCollectionView)
        self.view.bringSubview(toFront: appBar.headerViewController.headerView)
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
        self.delegate?.creatNewAlbumFinish(name: albumTitleText!)
    }
    
    @objc func addTextBarButtonItemTap(_ sender:UIBarButtonItem){
        headerExtensionArray.append(.textView)
//        self.photoCollectionView.performBatchUpdates({ [weak self] in
            self.headView?.headerExtensionArray = headerExtensionArray
            
//        }) { (finished) in
//
//        }
        self.photoCollectionView.reloadData()
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
//        let addLocationBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "location_new_album.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(addLocationBarButtonItemTap(_:)))
        let sortPhotoBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "sort_photo_new_album.png"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(sortPhotoBarButtonItemTap(_:)))
        self.navigationItem.rightBarButtonItems = [sortPhotoBarButtonItem,addTextBarButtonItem,addNewPhotoBarButtonItem]
        if let header = self.photoCollectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: IndexPath.init(row: 0, section: 0)){
            let headerView = header as! NewPhotoAlbumCollectionReusableView
            headerView.state = .editing
        }
    }
    
    func nomarlStateAction(){
        self.style = .whiteWithoutShadow
        self.navigationItem.leftBarButtonItem = nil
        self.photoCollectionView.reloadData()
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
        let asset = dataSource[indexPath.row]
        
        cell.setImagView(indexPath:indexPath)
        cell.setDeleteButton(indexPath: indexPath)
        cell.setEditingAnimation(isEditing: self.state == .editing ? true : false, animation: true)
//        setSelectAnimation(isSelect: self.isSelectMode ?? false ? self.choosePhotos.contains(model) : false, animation: false)
        cell.model = asset
//        cell.nameLabel.text = model.name
//        cell.countLabel.text = "100"
        cell.deleteCallbck = { [weak self] in
            self?.photoCollectionView.performBatchUpdates({
                self?.photoCollectionView.deleteItems(at: [indexPath])
            }, completion: { (finish) in
                
            })
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headView:NewPhotoAlbumCollectionReusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: reuseHeaderIdentifier, for: indexPath) as! NewPhotoAlbumCollectionReusableView
        headView.stateChangeClosure = { [weak self]  (headerState) in
            switch headerState {
            case .editing:
                self?.state = .editing
            case .normal:
                self?.state = .normal
            default:
                break
            }
        }
        headView.state = self.state == .normal ? .normal : .editing
        self.headView = headView
        return headView
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        if let header = self.photoCollectionView.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at:indexPath) as? NewPhotoAlbumCollectionReusableView{
          albumTitleText =  header.textField.text ?? LocalizedString(forKey: "未命名相册")
        }
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
        return  CGSize(width: __kWidth, height: headerExtensionArray.contains(HeaderExtensionType.textView) ? 175 + MarginsWidth + 88 + MarginsWidth : 175 )
    }
    
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
    //        return CGSize(width: cellContentSize, height: 8 + 14 + 8)
    //    }
    
}
