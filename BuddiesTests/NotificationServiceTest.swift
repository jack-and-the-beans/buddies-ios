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
    
    class TestCollection : CollectionReference {
        var test_token: String? = nil
        var doc = TestDoc()
        
        override func document(_ documentPath: String) -> DocumentReference {
            return doc
        }
        
        class TestDoc : DocumentReference {
            var test_token: String? = nil
            override func updateData(_ fields: [AnyHashable : Any], completion: ((Error?) -> Void)? = nil) {
                test_token = fields[AnyHashable("notification_token")] as? String
            }
            
            override func setData(_ documentData: [String : Any], merge: Bool, completion: ((Error?) -> Void)? = nil) {
                test_token = documentData["notification_token"] as? String
                if (test_token?.count == 0) {
                    let err = NSError(domain: "None", code: -1, userInfo: ["name": "none"])
                    guard let onErr = completion else { return }
                    
                    onErr(err)
                }
            }
            
            // THANK YOU STACK OVERFLOW: https://stackoverflow.com/a/47272501
            init(workaround _: Void = ()) {}
        }
        // THANK YOU STACK OVERFLOW: https://stackoverflow.com/a/47272501
        init(workaround _: Void = ()) {}
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
        override func saveTokenToFirestore(fcmToken: String, user: UserInfo? = Auth.auth().currentUser,
            collection: CollectionReference = Firestore.firestore().collection("users")) {
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
    
    class ExistingUser : NSObject, UserInfo {
        var providerID: String = "test"
        
        var displayName: String? = "test"
        
        var photoURL: URL? = nil
        
        var email: String? = "test"
        
        var phoneNumber: String? = "test"
        
        var uid: String = "test_uid"
    }

    

    func testTokenSaveNoUser() {
        let notificationTester = NotificationService()
        let collection = TestCollection()
        notificationTester.saveTokenToFirestore(
            fcmToken: "token_boi",
            user: nil,
            collection: collection
        )
        XCTAssert(collection.doc.test_token == nil, "Does not save token if user is not authenticated.")
    }

    func testTokenSave() {
        let notificationTester = NotificationService()
        let collection = TestCollection()
        let user = ExistingUser()
        notificationTester.saveTokenToFirestore(
            fcmToken: "token_boi",
            user: user,
            collection: collection
        )
        XCTAssert(collection.doc.test_token == "token_boi", "Saves token if user is authenticated.")
    }
    
    func testTokenError() {
        let notificationTester = NotificationService()
        let collection = TestCollection()
        let user = ExistingUser()
        notificationTester.saveTokenToFirestore(
            fcmToken: "",
            user: user,
            collection: collection
        )
        XCTAssert(true, "Does not crash on error throw")
    }
}

