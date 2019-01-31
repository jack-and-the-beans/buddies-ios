//
//  NotificationService.swift
//  Buddies
//
//  Created by Noah Allen on 1/31/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
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
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in})
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
