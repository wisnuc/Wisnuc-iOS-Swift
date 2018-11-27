//
//  AvatarChangeViewController.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/10/11.
//  Copyright © 2018 wisnuc-imac. All rights reserved.
//

import UIKit

class AvatarChangeViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        prepareNavigation()
        let imageURL = URL.init(string: AppUserService.currentUser?.avaterURL ?? "")
        avatarImageView.setImageWith(imageURL, placeholder: UIImage.init(named: "avatar_placeholder_big.png"))
        self.view.addSubview(headerView)
        self.view.addSubview(avatarImageView)
        // Do any additional setup after loading the view.
    }
    
    func prepareNavigation(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: LocalizedString(forKey: "更换头像"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(rightBarButtonItemTap(_ :)))
    }
    
    func changteAavator(image:UIImage){
        guard let imageData = image.compressQuality(withMaxLength: 400) else {
            Message.message(text: LocalizedString(forKey: "错误，无法跟换头像"))
            return
        }
        let reuqest = AvatarAPI.init()
        reuqest.uploadRequestJSONCompletionHandler(requestData: imageData, { (response) in
            if let error = response.error{
                SVProgressHUD.showError(withStatus: error.localizedDescription)
            }else{
                if let errorMessage = ErrorTools.responseErrorData(response.data){
                    SVProgressHUD.showError(withStatus: errorMessage)
                }else{
                    if  let rootDic = response.value as? NSDictionary{
                        if let url = rootDic["data"] as? String{
                            AppUserService.currentUser?.avaterURL = url
                            AppUserService.synchronizedCurrentUser()
                            SVProgressHUD.showSuccess(withStatus: LocalizedString(forKey: "头像更换成功"))
                        }
                    }
                }
            }
        })
    }
    
    @objc func rightBarButtonItemTap(_ sender:UIBarButtonItem){
        
        //初始化提示框
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //按钮：从相册选择，类型：UIAlertActionStyleDefault
        alert.addAction(UIAlertAction(title: "从相册选择", style: .default, handler: { action in
            //初始化UIImagePickerController
            let pickerImage = UIImagePickerController.init()
            //获取方式1：通过相册（呈现全部相册），UIImagePickerControllerSourceTypePhotoLibrary
            //获取方式2，通过相机，UIImagePickerControllerSourceTypeCamera
            //获取方法3，通过相册（呈现全部图片），UIImagePickerControllerSourceTypeSavedPhotosAlbum
            pickerImage.sourceType = .photoLibrary
            //允许编辑，即放大裁剪
            pickerImage.allowsEditing = true
            //自代理
            pickerImage.delegate = self
            //页面跳转
            self.present(pickerImage, animated: true)
        }))
        //按钮：拍照，类型：UIAlertActionStyleDefault
        alert.addAction(UIAlertAction(title: "拍照", style: .default, handler: { action in
            /**
             其实和从相册选择一样，只是获取方式不同，前面是通过相册，而现在，我们要通过相机的方式
             */
            let pickerImage = UIImagePickerController.init()
            //获取方式:通过相机
            pickerImage.sourceType = .camera
            pickerImage.allowsEditing = true
            pickerImage.delegate = self
            self.present(pickerImage, animated: true)
        }))
        //按钮：取消，类型：UIAlertActionStyleCancel
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    lazy var avatarImageView = UIImageView.init(frame: CGRect(x: 0, y: headerView.bottom + 1, width: __kWidth, height: __kWidth))
    
    lazy var headerView: UILabel = {
        let label = UILabel.init(frame: CGRect(x: MarginsWidth, y: MDCAppNavigationBarHeight + MarginsCloseWidth , width: __kWidth - MarginsWidth*2, height: 56))
        label.textColor = .white
        label.text = LocalizedString(forKey: "头像")
        label.font = UIFont.boldSystemFont(ofSize: 21)
        return label
    }()
}

extension AvatarChangeViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let newPhoto = info["UIImagePickerControllerEditedImage"] as? UIImage{
            avatarImageView.image = newPhoto
            dismiss(animated: true)
            changteAavator(image: newPhoto)
        }
    }
}
