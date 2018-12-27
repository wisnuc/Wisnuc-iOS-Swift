//
//  AppDelegate.swift
//  Wisnuc-iOS-Swift
//
//  Created by wisnuc-imac on 2018/4/10.
//  Copyright © 2018年 wisnuc-imac. All rights reserved.
//

import UIKit
import CoreData
import MaterialComponents
import RealReachability
import CatalogByConvention
import MagicalRecord
import SugarRecord
import Alamofire
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,WXApiDelegate{
    var networkStatus:WSNetworkStatus?{
        didSet{
            switch networkStatus {
            case .WIFI?: break
            case .ViaWWAN?:break
            case .Disconnected?: break
                
            default:
                break
            }
        }
    }
    var window: UIWindow?
    var loginController:LoginRootViewController?
    var colorScheme: (MDCColorScheme & NSObjectProtocol)!
    var coreDataContext: NSManagedObjectContext?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        redirectNSlogToDocumentFolder()
        IQKeyboardManager.shared.enable = true
        registerCoreDataContext()
        registerWeChat()   // Wechat
        colorScheme = MDCBasicColorScheme(primaryColor: COR1)
        startNotifierNetworkStutas() // networkObserveNotification
        initRootVC()
        return true
    }
    
    func initRootVC(){
        self.window?.rootViewController = nil
        
        // 取出之前保存的版本号
        let userDefaults = UserDefaults.standard
        let appVersion = userDefaults.string(forKey:kappVersionKey)
        
        // 如果 appVersion 为 nil 说明是第一次启动；如果 appVersion 不等于 currentAppVersion 说明是更新了
        if appVersion == nil || appVersion != kCurrentAppVersion {
            let indexVC = FirstLaunchViewController();
            window?.rootViewController = indexVC;
            userDefaults.set(kCurrentAppVersion, forKey:kappVersionKey)
            userDefaults.synchronize()
        } else{
            if AppUserService.isUserLogin && AppUserService.isStationSelected{
                didFinishLaunchingToMainScreen()
            }else{
                didFinishLaunchingToLogin()
            }
        }
         self.window?.makeKeyAndVisible()
    }
    
    func didFinishLaunchingToLogin(){
        let loginController = LoginRootViewController.init(.wechat)
        self.loginController = loginController;
        let navigationController = UINavigationController.init(rootViewController:loginController)
        self.window?.rootViewController = navigationController
    }
    
    func didFinishLaunchingToMainScreen(){
        self.getAllAsset()
        fetchCookie()
        getAllBackup()
        setAppNetworkState()
        setRootViewController()
        if let language = AppUserService.currentUser?.language?.intValue{
            let languageType = LanguageType(number: language)
            LocalizeHelper.instance.setLanguage(languageType.rawValue)
        }
        if  RealReachability.sharedInstance().currentReachabilityStatus() == .RealStatusViaWiFi && AppUserService.currentUser?.autoBackUp?.boolValue == true{
            guard let uuid = AppUserService.currentUser?.stationId else {
                return
            }
            AppService.sharedInstance().startAutoBackup(uuid: uuid) {
                
            }
        }
    }
    
    func registerWeChat(){
        WXApi.registerApp(KWxAppID)
    }
    
    func getAllBackup(){
        AppNetworkService.getUserAllBackupDrive { [weak self](error,driveModels) in

        }
    }
    
    func getAllAsset(){
        var all:Array<WSAsset> = Array.init()
        PHPhotoLibrary.getAllAsset { (result, assets) in
            for (_,value) in assets.enumerated(){
                let type = value.getWSAssetType()
                let duration = value.getDurationString()
                let asset = WSAsset.init(asset: value, type: type, duration: duration)
                all.append(asset)
            }
        }
        
        AppAssetService.allAssets = all
    }
    

    func registerCoreDataContext(){
        
        MagicalRecord.setupCoreDataStack()
        MagicalRecord.setLoggingLevel(MagicalRecordLoggingLevel.warn)
//        if #available(iOS 10.0, *) {
//            coreDataContext = self.persistentContainer.viewContext
//        } else {
//            // iOS 9.0 and below - however you were previously handling it
//            guard let modelURL = Bundle.main.url(forResource: "Wisnuc_iOS_Swift", withExtension:"momd") else {
//                fatalError("Error loading model from bundle")
//            }
//            guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
//                fatalError("Error initializing mom from: \(modelURL)")
//            }
//            let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
//            coreDataContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//            let docURL = urls[urls.endIndex-1]
//            let storeURL = docURL.appendingPathComponent("Model.sqlite")
//            do {
//                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
//            } catch {
//                fatalError("Error migrating store: \(error)")
//            }
//        }
    }
    
    func startNotifierNetworkStutas() {
        let realReachability = RealReachability.sharedInstance()
        realReachability?.startNotifier()
        NotificationCenter.default.addObserver(self, selector: #selector(networkChanged(_:)), name:NSNotification.Name.realReachabilityChanged , object: nil)
    }
    
    func setRootViewController(){
        let tabBarController = WSTabBarController ()
        
        let filesVC = FilesRootViewController()
        filesVC.selfState = .root
        filesVC.title = LocalizedString(forKey: "云盘")
        let photosVC = PhotoAlbumViewController.init(style: NavigationStyle.whiteWithoutShadow)
        photosVC.title = LocalizedString(forKey: "相簿")
        let devieceVC = DeviceViewController.init(style: NavigationStyle.whiteWithoutShadow)
        devieceVC.title = LocalizedString(forKey: "设备")
        
        let settingVC = SettingRootViewController.init(style: NavigationStyle.whiteWithoutShadow)
        let filesNavi = BaseNavigationController.init(rootViewController: filesVC)
        let photosNavi = BaseNavigationController.init(rootViewController: photosVC)
        let deviceNavi = BaseNavigationController.init(rootViewController: devieceVC)
        let settingNavi = BaseNavigationController.init(rootViewController: settingVC)
        
        filesNavi.tabBarItem = UITabBarItem(title:  LocalizedString(forKey: "云盘"), image: UIImage.init(named: "tab_files_selected.png")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), tag: 0)
        photosNavi.tabBarItem = UITabBarItem(title:  LocalizedString(forKey: "相簿"), image: UIImage.init(named: "tab_photos.png")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), tag: 1)
        deviceNavi.tabBarItem = UITabBarItem(title:  LocalizedString(forKey: "设备"), image: UIImage.init(named: "tab_device.png")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), tag: 2)
        settingNavi.tabBarItem = UITabBarItem(title:  LocalizedString(forKey: "我的"), image: UIImage.init(named: "tab_my.png")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), tag: 3)
        filesNavi.tabBarItem.selectedImage = UIImage.init(named: "tab_files_selected.png")
       
        let controllers = [filesNavi,photosNavi,deviceNavi,settingNavi]
        tabBarController.viewControllers = controllers
        tabBarController.selectedViewController = controllers[0]
        
        
        tabBarController.tabBar?.items = [filesNavi.tabBarItem,
                                          photosNavi.tabBarItem,
                                          deviceNavi.tabBarItem,
                                          settingNavi.tabBarItem]
        tabBarController.tabBar?.setImageTintColor(COR1, for: MDCTabBarItemState.normal)
        tabBarController.tabBar?.setImageTintColor(LightGrayColor, for: MDCTabBarItemState.selected)
        tabBarController.tabBar?.selectedItem = tabBarController.tabBar?.items[0]
        tabBarController.tabBar?.selectedItem?.image = tabBarController.tabBar?.selectedItem?.selectedImage!
        tabBarController.tabBar?.itemAppearance = MDCTabBarItemAppearance.titledImages
        MDCTabBarColorThemer.apply(appDelegate.colorScheme, to: tabBarController.tabBar!)
        
        tabBarController.tabBar?.backgroundColor = UIColor.white
        tabBarController.tabBar?.selectedItemTintColor = COR1
        tabBarController.tabBar?.unselectedItemTintColor = LightGrayColor

        window?.rootViewController = tabBarController
        if loginController != nil {
            loginController = nil
        }
    }
    
    func setAppNetworkState(){
        if networkStatus != nil {
            AppNetworkService.changeNet(networkStatus!)
        }else{
           let status = RealReachability.sharedInstance().currentReachabilityStatus()
           checkNetworkStatus(status: status)
        }
    }
    
    func fetchCookie(){
        Alamofire.request(kCloudBaseURL).validate().responseData { (response) in
            guard let header = response.response?.allHeaderFields else {
                return
            }
            guard let cookie = header["Set-Cookie"] as? String else {
                return
            }
            
            AppUserService.currentUser?.cookie = cookie
            AppUserService.synchronizedCurrentUser()
        }
    }
    
    @objc func networkChanged(_ noti:NSNotification){
        let realReachability = noti.object as! RealReachability?
        let status = realReachability?.currentReachabilityStatus()
        checkNetworkStatus(status: status!)
    }
    
    func checkNetworkStatus(status:ReachabilityStatus) {
        switch status {
        case .RealStatusNotReachable:
            networkStatus = WSNetworkStatus.Disconnected
        case .RealStatusViaWiFi:
            networkStatus = WSNetworkStatus.WIFI
        case .RealStatusViaWWAN:
            networkStatus = WSNetworkStatus.ViaWWAN
        default:
            break
        }
        AppNetworkService.changeNet(networkStatus!)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        if #available(iOS 10.0, *) {
            self.saveContext()
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        let res:Bool = WXApi.handleOpen(url, delegate: self)
        return res;
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let res:Bool = WXApi.handleOpen(url, delegate: self)
        return res;
    }
    
    // MARK: - WXDelegate
    
    func onReq(_ req: BaseReq!) {
        
    }
    
    func onResp(_ resp: BaseResp!) {
        let errorCodeInt32: Int32 = resp.errCode
        let errorCodeInt = Int(errorCodeInt32)
        switch  errorCodeInt {
        case Int((WXSuccess).rawValue): //用户同意
            Message.message(text: "授权成功")
            if resp is SendAuthResp{
                wechatCallBackControllerAction(resp)
            }
        case Int(WXErrCodeAuthDeny.rawValue)://用户拒绝授权
            Message.message(text: "用户拒绝授权")
        case Int(WXErrCodeSentFail.rawValue)://发送失败
            Message.message(text: "用户拒绝授权")
        case Int(WXErrCodeUnsupport.rawValue)://不支持
            Message.message(text: "用户拒绝授权")
        case Int(WXErrCodeUserCancel.rawValue)://用户取消
            Message.message(text: "用户拒绝授权")
        default:
            break
        }
    }
    
    
    func wechatCallBackControllerAction(_ resp:BaseResp){
        let aresp = resp as! SendAuthResp
        if let controller = UIViewController.currentViewController(){
            if  controller.isKind(of: LoginRootViewController.self){
                let loginVC = UIViewController.currentViewController() as! LoginRootViewController
                loginVC.weChatCallBackRespCode(code: aresp.code)
            }
            if  controller.isKind(of: MyBindWechatViewController.self){
                let bindVC = UIViewController.currentViewController() as! MyBindWechatViewController
                bindVC.weChatCallBackRespCode(code: aresp.code)
            }
        }
    }
    #if DEBUG
    func redirectNSlogToDocumentFolder() {
//        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        let documentsDirectory = paths[0]
//        let formatter = DateFormatter()
//        formatter.dateFormat = "dd-MM-yyyy"
//        let dateString = formatter.string(from: Date())
//        let fileName = "\(dateString).log"
//        let logFilePath = (documentsDirectory as NSString).appendingPathComponent(fileName)
//        var dump = ""
//
//
//        if FileManager.default.fileExists(atPath: logFilePath) {
//            dump =  try! String(contentsOfFile: logFilePath, encoding: String.Encoding.utf8)
//        }
//        do {
//            // Write to the file
//            try  "\(dump)\n\(Date())".write(toFile: logFilePath, atomically: true, encoding: String.Encoding.utf8)
//
//        } catch let error as NSError {
//            print("Failed writing to log file: \(logFilePath), Error: " + error.localizedDescription)
//        }
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let dateString = formatter.string(from: Date())
        let fileName = "\(dateString).log"
        let logPath = documentsDirectory.appendingPathComponent(fileName)
        let cstr = (logPath as NSString).utf8String
        freopen(cstr, "a+", stderr)
        
//        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        let documentDirectory = paths[0]
//        let fileName = "winsun.log" // 注意不是NSData!
//        let logFilePath = URL(fileURLWithPath: documentDirectory).appendingPathComponent(fileName).absoluteString
//        if FileManager.default.fileExists(atPath: logFilePath){
//
//        }
//        // 先删除已经存在的文件
//        //    NSFileManager *defaultManager = [NSFileManager defaultManager];
//        //    [defaultManager removeItemAtPath:logFilePath error:nil];
//
//        // 将log输入到文件
//        freopen(logFilePath.cString(using: String.Encoding(rawValue: String.Encoding.ascii.rawValue)), "a+", stdout)
//        freopen(logFilePath.cString(using: String.Encoding(rawValue: String.Encoding.ascii.rawValue)), "a+", stderr)
    }
    #endif
    
    // MARK: - Core Data stack
    

    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Wisnuc_iOS_Swift")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    @available(iOS 10.0, *)
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

