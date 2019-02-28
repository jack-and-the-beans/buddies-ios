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

// Protocols for dependency injection:
// Essetially, these classes (e.g. `InstanceID` and `UNUserNotificationCenter`) already
// implement these methods. The protocols are so that we can mock the protocol, and then
// inject just the methods we need for the tests.
protocol InstanceIDProtocol {
    func instanceID (handler:  @escaping InstanceIDResultHandler)
}
extension InstanceID: InstanceIDProtocol {}

protocol NotificationProtocol {
    func requestAuthorization (options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void)
}
extension UNUserNotificationCenter: NotificationProtocol {}


class NotificationService: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func registerForNotifications
        (instanceId: InstanceIDProtocol = InstanceID.instanceID(),
         notifications: NotificationProtocol = UNUserNotificationCenter.current()) {

        let authOptions: UNAuthorizationOptions = [.alert]
        notifications.requestAuthorization(options: authOptions) { granted, error in
            // Get current notification token. We have to do this because messaging
            // receives the token before we are authenticated, meaning that we need
            // to retreive it ourselves:
            guard granted else { return }
            instanceId.instanceID(handler: { (res, err) in
                guard let token = res?.token else { return }
                self.saveTokenToFirestore(fcmToken: token)
            })
        }
    }

    // Saves the user's notification token whenever it updates:
    // Note: the token will save even if we don't have notification
    // permission. This is OK because iOS will handle that case
    // for us. I removed the check for notification permission
    // because it was not possible to subclass for mocking.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        self.saveTokenToFirestore(fcmToken: fcmToken)
    }

    // Pushes the token to firestore if:
    // 1. The token exists
    // 2. The user is authenticated
    func saveTokenToFirestore(
        fcmToken: String,
        user: UserInfo? = Auth.auth().currentUser,
        collection: CollectionReference = Firestore.firestore().collection("accounts")) {
        
        guard let uid = user?.uid else { return }

        collection.document(uid).setData([
                "notification_token" : fcmToken
        ], merge: true) {err in
            if let err = err {
                print("Error updating document: \(err)")
            }
        }
    }
}
