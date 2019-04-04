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
    var pendingNotificationToLoad: ActivityNotificationInfo?
    var notifications: NotificationService = NotificationService()
    var window: UIWindow?
    var topicCollection: TopicCollection!
    
    var loginListenerCancel: Canceler!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // This will get us a token, even if we don't save
        // it until we have notification permission.
        application.registerForRemoteNotifications()
        
        //Uncomment below to play with dev data (or Record UI Test in dev)
//        let filename = "GoogleService-Info-Dev"
        let filename = CommandLine.arguments.contains("--uitesting") ? "GoogleService-Info-Dev" : "GoogleService-Info-Prod"
        guard let firebaseConfigPath = Bundle.main.path(forResource: filename, ofType: "plist") else { fatalError() }
        
        // Initialize
        FirebaseApp.configure(options: FirebaseOptions(contentsOfFile: firebaseConfigPath)!)
        topicCollection = TopicCollection()
        
        if CommandLine.arguments.contains("--uitesting") {
            UIView.setAnimationsEnabled(false)
            do { try Auth.auth().signOut() }
            catch { print("Error signing out for testing, \(error)") }
        }
        
        // Setup delegates for notifications:
        UNUserNotificationCenter.current().delegate = self.notifications
        Messaging.messaging().delegate = self.notifications
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.tintColor = Theme.theme
        initLoginListener(launchOptions: launchOptions)
        
        pendingNotificationToLoad = NotificationService.getNotificationInfo(from: launchOptions)
        
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func initLoginListener(data: DataAccessor = DataAccessor.instance, launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) {
        
        // Last login state -> initially none.
        var wasLoggedIn: Bool? = nil
        var wasAUserDoc: Bool? = nil
        
        // set the view to the launch screen until we're ready for more
        window?.rootViewController = BuddiesStoryboard.LaunchScreen.viewController()
        
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
                   needsAccountInfo: Bool,
                   notificationInfo: ActivityNotificationInfo? = nil) {
        if isLoggedOut {
            setWindow(isInitial, vc: BuddiesStoryboard.Login.viewController())
        }
        else if needsAccountInfo {
            self.setWindow(isInitial, vc: BuddiesStoryboard.Login.viewController(withID: "SignUpInfo"))
        }
        else {
            self.setWindow(isInitial, vc: BuddiesStoryboard.Main.viewController())
            self.handleLaunchFromNotification()
        }
    }

    // Called if receiving a notification while the app is running but in the background:
    func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable: Any]) {
        // Do NOT navigate to the activities screen while the
        // user is already using the app!
        guard application.applicationState != .active else { return }
        self.pendingNotificationToLoad = NotificationService.getNotificationInfo(from: notification)
        self.handleLaunchFromNotification()
    }

    // Handles launch if we have an activity ID from a notification.
    // Called with nil if there is no activityID on launch.
    func handleLaunchFromNotification() {
        guard let activityId = self.pendingNotificationToLoad?.activityId,
              let destination = self.pendingNotificationToLoad?.navigationDestination,
              let tabController = window?.rootViewController as? UITabBarController,
              let controllers = tabController.viewControllers else { return }
        
        // Find the table from which we want to show the activity
        // Only runs on the nav controlers under the tab bar
        var activityTable: ActivityTableVC?
        for case let controller as UINavigationController in controllers {
            if (destination == "discover") {
                for case let subView as DiscoverTableVC in controller.viewControllers {
                    tabController.selectedIndex = 0;
                    activityTable = subView
                    break
                }
            } else if destination == "my_activities" {
                for case let subView as MyActivitiesVC in controller.viewControllers {
                    tabController.selectedIndex = 2;
                    activityTable = subView
                    break
                }
            }
            if (activityTable != nil) {
                break
            }
        }
        activityTable?.showActivity(with: activityId)
        
        // Clear pending notification if we're able to show the activity
        self.pendingNotificationToLoad = nil
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        loginListenerCancel()
    }
}
