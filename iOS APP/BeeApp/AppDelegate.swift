//
//  AppDelegate.swift
//  BeeApp
//
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import FBSDKCoreKit
import Firebase
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var tabBarLoaded:(()->())?
    var statusBarStyle: UIStatusBarStyle = .default
    var isStatusBarHidden: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        configFirebase()
        // Facebook configuration
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        configAppDesigns()
        IQKeyboardManager.shared.enable = true
        configDirectLoggedIn()
        requestForPushNotification()
        return true
    }

    func configFirebase() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Dreamli")
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
    
    func application(
            _ app: UIApplication,
            open url: URL,
            options: [UIApplication.OpenURLOptionsKey : Any] = [:]
        ) -> Bool {

            ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )

        }

}

//MARK:- Config(s)
extension AppDelegate {
    func configAppDesigns() {
        YZAppConfig.initialise(414, designHeight: 896, navigationBarHeight: 44)
    }
    
    func configDirectLoggedIn() {
        if checkForUser() {
            navigateToUserTabBar(true)
        }
    }
    
    
    //It will call when application didFinish launching.
    //It will check stored login user information.
    func checkForUser() -> Bool {
        let arrUser = YZLoggedInUser.fetchDataFromEntity(predicate: nil, sortDescs: nil)
        if arrUser.isEmpty {
            return false
        }else{
            YZApp.shared.objLogInUser = arrUser.first
            return YZApp.shared.objLogInUser != nil
        }
    }
    
    func navigateToUserTabBar(_ isDirectLogin: Bool = false) {
        //TabBar
        let sbTabBar = UIStoryboard(name: "Tabbar", bundle: nil)
        let vcUserTabBar = sbTabBar.instantiateViewController(withIdentifier: "YZTabbarVC") as! YZTabbarVC
        if let window = window {
            if let vcRoot = window.rootViewController, let vcNavigation = vcRoot as? UINavigationController {
                vcNavigation.viewControllers.append(vcUserTabBar)
                yzPrint(items: #function + " " + vcNavigation.viewControllers.debugDescription)
            }
        }
    }
    
    func logout() {
        YZLoggedInUser.deleteAllRecords()
        YZApp.shared.removedAuthoriaztionToken()
        window?.rootViewController = UIStoryboard(name: "Entry", bundle: nil).instantiateInitialViewController()
    }
}


//MARK: Firebase
extension AppDelegate: MessagingDelegate {

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        yzPrint(items: #function + " : " + fcmToken ?? " ")
              YZApp.shared.setAPNS(deviceToken: fcmToken) //Set fcmToken to UserDefault
    }
}

//MARK: UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func requestForPushNotification(_ completionHandler: ((Bool)->())? = nil) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) {[weak self](isGranted, error) in
            guard let weakSelf = self else{return}
            if let error = error {
                YZValidationToast.shared.showToastOnStatusBar(error.localizedDescription)
            }else if isGranted {
                yzPrint(items: #function + " : " + "APNS access granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications();
//                    weakSelf.registerPush()
                    completionHandler?(true)
                }
            }else{
                yzPrint(items: #function + " : " + "APNS access not granted")
                DispatchQueue.main.async {
                    UIApplication.shared.unregisterForRemoteNotifications()
                    completionHandler?(false)
                }
                //YZValidationToast.shared.showToastOnStatusBar(YZApp.shared.getLocalizedText("notification_denied"))
            }
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken //Set deviceToken to Messaging
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        yzPrint(items: #function + " : " + error.localizedDescription)
    }

    //Called when application in foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        yzPrint(items: "====================== APNS UserInfo ======================")
        yzPrint(items: "APNS UserInfo : " + String(describing: notification.request.content.userInfo.description))
//        if let dictJSON = notification.request.content.userInfo as? [String : Any], let _ = YZRedirection(dictJSON) {
//            if let vcNotification = window?.visibleViewController() as? NotificationListVC {
//                vcNotification.refreshNotifications()
//            }
//        }
        completionHandler([.alert, .sound, .badge])
    }

    //Called when application in background or killed.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        yzPrint(items: "====================== APNS UserInfo ======================")
        yzPrint(items: "APNS UserInfo : " + String(describing: response.notification.request.content.userInfo.description))
//        if let dictJSON = response.notification.request.content.userInfo as? [String : Any],
//            let objRedirection = YZRedirection(dictJSON),
//            YZApp.shared.isUserLoggedIn {
//            navigateUsing(objRedirection)
//        }
        completionHandler()
    }
}
