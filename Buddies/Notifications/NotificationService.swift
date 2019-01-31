//
//  NotificationService.swift
//  Buddies
//
//  Created by Noah Allen on 1/31/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//
// Thanks to Ray Wenderlich for the notification tutorial: https://www.raywenderlich.com/8164-push-notifications-tutorial-getting-started
// Also see the firebase documentation for cloud messaging: https://firebase.google.com/docs/cloud-messaging/ios/first-message#register_for_remote_notifications
//

import Foundation
import UserNotifications
import FirebaseMessaging
import FirebaseFirestore
import FirebaseAuth

class NotificationService: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    private var firestore: Firestore? = nil
    
    static func registerForNotifications () {
        let authOptions: UNAuthorizationOptions = [.alert]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            guard granted else { return }
            self.getNotificationSettings()
        }
    }

    static func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    // Sends user's notification token to Firestore whenever it updates:
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        guard let db = self.firestore else { return }
        guard let usr = Auth.auth().currentUser else { return }
        
        db.collection("users").document(usr.uid).updateData([
            "notification_token" : fcmToken
        ]) {err in
            if let err = err {
                print("Error updating document: \(err)")
            }
        }
    }

    func setFirestore(firestore: Firestore) {
        self.firestore = firestore
    }
}
