//
//  NotificationServiceTest.swift
//  BuddiesTests
//
//  Created by Noah Allen on 1/31/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import XCTest
import FirebaseInstanceID
import FirebaseMessaging
import FirebaseFirestore
import UserNotifications
import FirebaseAuth

@testable import Buddies

class NotificationServiceTest: XCTestCase {
    let notificationService = NotificationService()
    
    class MockInstanceID: InstanceIDProtocol {
        func instanceID(handler:  @escaping InstanceIDResultHandler) {
            let res = InstanceResultMock()
            handler(res, nil)
        }
    }

    class InstanceResultMock: InstanceIDResult {
        override var token: String {
            get {
                return "hello"
            }
        }
    }

    class NotificationAcceptMock: NotificationProtocol {
        func requestAuthorization (options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
            completionHandler(true, nil)
        }
    }

    class NotificationDenyMock: NotificationProtocol {
        func requestAuthorization (options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
            completionHandler(false, nil)
        }
    }
    
    class TokenTester: NotificationService {
        var token: String? = nil
        override func saveTokenToFirestore(fcmToken: String, user: UserInfo? = nil,
            collection: CollectionReference = MockCollectionReference()) {
            self.token = fcmToken
        }
    }
    
    func testTokenSavedOnPermissionGrant () {
        let notificationTester = TokenTester()
        notificationTester.registerForNotifications(
            instanceId: MockInstanceID(),
            notifications: NotificationAcceptMock())
        XCTAssert(notificationTester.token == "hello", "Saves token when permission is granted.")
    }
    
    func testTokenNotSavedOnPermissionDeny () {
        let notificationTester = TokenTester()
        notificationTester.registerForNotifications(
            instanceId: MockInstanceID(),
            notifications: NotificationDenyMock())
        XCTAssert(notificationTester.token == nil, "Does not save token when permission is denied.")
    }
    
    func testTokenSavedOnTokenUpdate () {
        let notificationTester = TokenTester()
        notificationTester.messaging(
            Messaging.messaging(),
            didReceiveRegistrationToken: "hello")
        XCTAssert(notificationTester.token == "hello", "Saves token when messaging updates token")
    }
    

    func testTokenSaveNoUser() {
        let notificationTester = NotificationService()
        let collection = MockCollectionReference()
        notificationTester.saveTokenToFirestore(
            fcmToken: "token_boi",
            user: nil,
            collection: collection
        )
        let doc = collection.document("test_uid") as! MockDocumentReference
        XCTAssert(doc.exposedData["notification_token"] == nil, "Does not save token if user is not authenticated.")
    }

    func testTokenSave() {
        let notificationTester = NotificationService()
        let collection = MockCollectionReference()
        let user = MockExistingUser()
        notificationTester.saveTokenToFirestore(
            fcmToken: "token_boi",
            user: user,
            collection: collection
        )
        let doc = collection.document("test_uid") as! MockDocumentReference
        XCTAssert(doc.exposedData["notification_token"] as! String == "token_boi", "Saves token if user is authenticated.")
    }
    
    func testTokenError() {
        let notificationTester = NotificationService()
        let collection = MockCollectionReference()
        let user = MockExistingUser()
        notificationTester.saveTokenToFirestore(
            fcmToken: "",
            user: user,
            collection: collection
        )
        XCTAssert(true, "Does not crash on error throw")
    }
    
    func testGetNotificationInfoLaunchOptions () {
        let userInfo: [AnyHashable: Any] = [
            "activity_id": "abc",
            "nav_dest": "123"
        ]
        let notification: [String: Any] = [
            "userInfo": userInfo
        ]
        let launchOptions = [
            UIApplication.LaunchOptionsKey.remoteNotification: notification
        ]
        
        let res = NotificationService.getNotificationInfo(from: launchOptions)
        XCTAssert(res?.activityId == "abc")
        XCTAssert(res?.navigationDestination == "123")
    }
    
    // Returns nil when the info can't be found:
    func testGetNotificationInfoLaunchOptionsNil () {
        let launchOptions: [UIApplication.LaunchOptionsKey: Any] = [:]
        
        let res = NotificationService.getNotificationInfo(from: launchOptions)
        XCTAssert(res == nil)
    }
    
    func testGetNotificationInfoNotificationData () {
        let userInfo: [AnyHashable: Any] = [
            "activity_id": "abc",
            "nav_dest": "123"
        ]
        
        let res = NotificationService.getNotificationInfo(from: userInfo)
        XCTAssert(res?.activityId == "abc")
        XCTAssert(res?.navigationDestination == "123")
    }
    
    // Returns nil when the activity ID can't be found:
    func testGetNotificationInfoDataNil () {
        let userInfo: [AnyHashable: Any] = [
            "nav_dest": "123"
        ]
        
        let res = NotificationService.getNotificationInfo(from: userInfo)
        XCTAssert(res == nil)
    }
}

