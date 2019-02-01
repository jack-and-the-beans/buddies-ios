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
import FirebaseInstanceID
import FirebaseAuth

class NotificationService: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    static func registerForNotifications () {
        let authOptions: UNAuthorizationOptions = [.alert]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            // Get current notification token. We have to do this because messaging
            // receives the token before we are authenticated, meaning that we need
            // to retreive it ourselves:
            InstanceID.instanceID().instanceID(handler: { (res, err) in
                guard let token = res?.token else { return }
                self.saveTokenToFirestore(fcmToken: token)
            })
        }
    }

    // Saves the user's notification token whenever it updates:
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        NotificationService.saveTokenToFirestore(fcmToken: fcmToken)
    }

    // Pushes the token to firestore if:
    // 1. The user has enabled notifications
    // 2. The token exists
    // 3. The user is authenticated
    static func saveTokenToFirestore(fcmToken: String) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            guard let usr = Auth.auth().currentUser else { return }
            
            Firestore.firestore().collection("users").document(usr.uid).updateData([
                    "notification_token" : fcmToken
            ]) {err in
                if let err = err {
                    print("Error updating document: \(err)")
                }
            }
        }
    }
}
