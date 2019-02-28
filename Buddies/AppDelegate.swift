//
//  AppDelegate.swift
//  Buddies
//
//  Created by Noah Allen on 1/23/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var notifications: NotificationService = NotificationService()
    var window: UIWindow?
    var topicCollection: TopicCollection!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // This will get us a token, even if we don't save
        // it until we have notification permission.
        application.registerForRemoteNotifications()
        
        // Initialize
        FirebaseApp.configure()
        topicCollection = TopicCollection()
        
        // Setup delegates for notifications:
        UNUserNotificationCenter.current().delegate = self.notifications
        Messaging.messaging().delegate = self.notifications
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let authHandler = AuthHandler(auth: Auth.auth())
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let _ = user { AppContent.setup() }
        }

        setupInitialView(isLoggedIn: authHandler.isLoggedIn()) { callback in
            getHasUserDoc(callback: callback)
        }
        
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func getHasUserDoc(callback: @escaping (Bool) -> Void,
                     uid: String? = Auth.auth().currentUser?.uid,
                     dataAccess: DataAccessor? = DataAccessor.instance,
                     src: CollectionReference = Firestore.firestore().collection("accounts")) {
        // If we're not logged in, there is no doc
        guard let uid = uid else {
            callback(false)
            return
        }
        
        // If the user is cached, it's already fine
        if dataAccess?.isUserCached(id: uid) ?? false {
            callback(true)
            return
        }
        
        // Otherwise reload it and make sure it parses correctly
        src.document(uid).getDocument { (snap, err) in
            if let snap = snap, let _ = OtherUser.from(snap: snap) {
                callback(true)
            }
            else {
                callback(false)
            }
        }
    }
    
    func tryLoadMainPage(getUserIsFilledOut: (@escaping (Bool) -> Void) -> Void) {
        getUserIsFilledOut { userIsFilledOut in
            if userIsFilledOut {
                self.window?.rootViewController = BuddiesStoryboard.Main.viewController()
            }
            else {
                self.window?.rootViewController = BuddiesStoryboard.Login.viewController(withID: "SignUpInfo")
            }
        }
    }
        
    func setupInitialView(isLoggedIn: Bool, getUserIsFilledOut: (@escaping (Bool) -> Void) -> Void) {
        if isLoggedIn {
            // set the view to the launch screen intil we're ready for more
            self.window?.rootViewController = BuddiesStoryboard.LaunchScreen.viewController()
            tryLoadMainPage(getUserIsFilledOut: getUserIsFilledOut)
        } else {
            // Show login page
            self.window?.rootViewController = BuddiesStoryboard.Login.viewController()
        }
    }
    
    /*

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
    }
    */
}

