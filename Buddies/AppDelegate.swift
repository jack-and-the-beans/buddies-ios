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
    
    var loginListenerCancel: Canceler!
    
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
        
        initLoginListener()
        
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func initLoginListener(data: DataAccessor = DataAccessor.instance) {
        
        // Last login state -> initially none.
        var wasLoggedIn: Bool? = nil
        var wasAUserDoc: Bool? = nil
        
        loginListenerCancel = data.useLoggedInUser { user in
            // Current login state.
            let isLoggedIn = Auth.auth().currentUser != nil
            let isAUserDoc = user != nil
            let isInitial = wasLoggedIn == nil
            
            // Find if there is a diff
            let authHasChanged = wasLoggedIn != isLoggedIn
                || isAUserDoc != wasAUserDoc
            
            // Store as last state
            wasLoggedIn = isLoggedIn
            wasAUserDoc = isAUserDoc
            
            
            if authHasChanged {
                // Navigates to the appropriate view of:
                //  - Login
                //  - Account Setup
                //  - Main
                self.setupView(isLoggedOut: !isLoggedIn,
                               isInitial: isInitial,
                               needsAccountInfo: isLoggedIn && !isAUserDoc)
                
                // If we are logged in, setup other app content.
                if isLoggedIn {
                    AppContent.setup()
                }
            }
        }
    }
    
    private func setWindow(_ isInitial: Bool, vc: UIViewController) {
        if isInitial {
            self.window?.rootViewController = vc
        }
        else {
            UIApplication.setRootView(vc)
        }
    }
    
    func setupView(isLoggedOut: Bool,
                   isInitial: Bool,
                   needsAccountInfo: Bool) {
        if isLoggedOut {
            setWindow(isInitial, vc: BuddiesStoryboard.Login.viewController())
            return
        }
        
        if isInitial {
            // set the view to the launch screen
            //  until we're ready for more
            setWindow(isInitial, vc: BuddiesStoryboard.LaunchScreen.viewController())
        }
        
        if needsAccountInfo {
            self.setWindow(isInitial, vc: BuddiesStoryboard.Login.viewController(withID: "SignUpInfo"))
        }
        else {
            self.setWindow(isInitial, vc: BuddiesStoryboard.Main.viewController())
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
    */

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        loginListenerCancel()
    }
}
