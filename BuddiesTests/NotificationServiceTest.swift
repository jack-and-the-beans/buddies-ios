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
import UserNotifications

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
        override func saveTokenToFirestore(fcmToken: String) {
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
    
    func testTokenSave() {
        
    }
}
