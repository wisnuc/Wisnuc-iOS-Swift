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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,WXApiDelegate{
    var networkStatus:WSNetworkStatus?
    var window: UIWindow?
    var _loginController:LoginViewController?
    var colorScheme: (MDCColorScheme & NSObjectProtocol)!
    var coreDataContext: NSManagedObjectContext?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        registerCoreDataContext()
        registerWeChat()   // Wechat
        colorScheme = MDCBasicColorScheme(primaryColor: COR1)
        startNotifierNetworkStutas() // networkObserveNotification
        MDCAlertColorThemer.apply(colorScheme)
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
            if AppUserService.isUserLogin{
                setRootViewController()
            }else{
                let type:LoginState?
                type = TokenManager.wechatLoginToken() != nil && (TokenManager.wechatLoginToken()?.count)!>0 ? .token:.wechat
                let loginController = LoginViewController.init(type!)
                _loginController = loginController;
                UIApplication.shared.statusBarStyle = .lightContent
                let navigationController = UINavigationController.init(rootViewController:loginController)
                self.window?.rootViewController = navigationController
            }
        }
        
         self.window?.makeKeyAndVisible()
    }
    
    func registerWeChat(){
        WXApi.registerApp(KWxAppID)
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
        filesVC.title = LocalizedString(forKey: "Files")
        let photosVC = BaseViewController()
        photosVC.title = "Downloads"
        photosVC.view.backgroundColor = UIColor.blue
        let shareVC = BaseViewController()
        shareVC.title = "History"
        shareVC.view.backgroundColor = UIColor.cyan
        
        let filesNavi = BaseNavigationController.init(rootViewController: filesVC)
        let photosNavi = BaseNavigationController.init(rootViewController: photosVC)
        let shareNavi = BaseNavigationController.init(rootViewController: shareVC)
        filesNavi.tabBarItem = UITabBarItem(title:  LocalizedString(forKey: "files"), image: UIImage.init(named: "warning.png")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal), selectedImage: UIImage.init(named: "tab_files.png")?.withRenderingMode(UIImageRenderingMode.alwaysOriginal))
        photosNavi.tabBarItem = UITabBarItem(title:  LocalizedString(forKey: "files"), image: UIImage.init(named: "Home"), selectedImage: UIImage.init(named: "tab_files.png"))
        shareNavi.tabBarItem = UITabBarItem(title:  LocalizedString(forKey: "files"), image: UIImage.init(named: "Home"), selectedImage: UIImage.init(named: "tab_files.png"))
        
        let controllers = [filesNavi, photosNavi, shareNavi]
        tabBarController.viewControllers = controllers
        tabBarController.tabBar?.items = [filesNavi.tabBarItem,
                                          photosNavi.tabBarItem ,
                                          shareNavi.tabBarItem]
        tabBarController.tabBar?.setImageTintColor(COR1, for: MDCTabBarItemState.normal)
        tabBarController.tabBar?.setImageTintColor(LightGrayColor, for: MDCTabBarItemState.selected)
        tabBarController.tabBar?.selectedItem = tabBarController.tabBar?.items[0]
        tabBarController.selectedViewController = controllers[0]
        tabBarController.tabBar?.itemAppearance = MDCTabBarItemAppearance.titledImages
        MDCTabBarColorThemer.apply(appDelegate.colorScheme, to: tabBarController.tabBar!)
        
        tabBarController.tabBar?.backgroundColor = UIColor.white
        tabBarController.tabBar?.selectedItemTintColor = COR1
        tabBarController.tabBar?.unselectedItemTintColor = LightGrayColor
        let drawerVC = DrawerViewController.init()
        let naviNavigationDrawer = AppNavigationDrawerController(rootViewController: tabBarController, leftViewController: drawerVC, rightViewController: nil)
        window?.rootViewController = naviNavigationDrawer
    }
    
    @objc func networkChanged(_ noti:NSNotification){
        let realReachability = noti.object as! RealReachability?
        let status = realReachability?.currentReachabilityStatus()
        switch status! {
        case .RealStatusNotReachable:
            return networkStatus = WSNetworkStatus.Disconnected
        case .RealStatusViaWiFi:
            return networkStatus = WSNetworkStatus.WIFI
        case .RealStatusViaWWAN:
            return networkStatus = WSNetworkStatus.ViaWWAN
        default:
            
            break
        }
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
            let aresp = resp as! SendAuthResp
            if  UIViewController.currentViewController().isKind(of: LoginViewController.self){
                let loginVC = UIViewController.currentViewController() as! LoginViewController
                loginVC.weChatCallBackRespCode(code: aresp.code)
            }
//            SendAuthResp *aresp = (SendAuthResp *)resp;
//            NSLog(@"%@",NSStringFromClass([[UIViewController getCurrentVC] class]));
//            if ([[UIViewController getCurrentVC] isKindOfClass:[FMLoginViewController class]]) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [(FMLoginViewController *)[UIViewController getCurrentVC] weChatCallBackRespCode:aresp.code];
//                    });
//            }else  if([[UIViewController getCurrentVC] isKindOfClass:[FMUserEditVC class]]){
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [(FMUserEditVC *)[UIViewController getCurrentVC] weChatCallBackRespCode:aresp.code];
//                    });
//            }else  if([[UIViewController getCurrentVC] isKindOfClass:[WBInitializationViewController class]]){
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [(WBInitializationViewController *)[UIViewController getCurrentVC] weChatCallBackRespCode:aresp.code];
//                    });
//            }else{
//                [SXLoadingView hideProgressHUD];
//            }
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

