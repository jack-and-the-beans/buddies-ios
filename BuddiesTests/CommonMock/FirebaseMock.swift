//
//  FirebaseMock.swift
//  BuddiesTests
//
//  Created by Luke Meier on 2/4/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import Firebase

class MockExistingUser : NSObject, UserInfo {
    var providerID: String = "test"
    
    var displayName: String? = "test"
    
    var photoURL: URL? = nil
    
    var email: String? = "test"
    
    var phoneNumber: String? = "test"
    
    var uid: String = "test_uid"
    
    override func delete
}

class MockCollectionReference : CollectionReference {
    var documents = [String: MockDocumentReference]()
    
    override func document(_ documentPath: String) -> DocumentReference {
        if let document = documents[documentPath] {
            return document
        } else {
            let doc = MockDocumentReference()
            documents[documentPath] = doc
            return doc
        }
    }
    // THANK YOU STACK OVERFLOW: https://stackoverflow.com/a/47272501
    init(workaround _: Void = ()) {}
}

class MockDocumentReference : DocumentReference {
    var exposedData = [String: Any]()
    override func updateData(_ fields: [AnyHashable : Any], completion: ((Error?) -> Void)? = nil) {
        if let data = fields as? [String: Any] {
            //Update exposedData
            data.forEach { (k,v) in exposedData[k] = v }
            completion?(nil)
        } else {
            completion?(NSError(domain: "Testing", code: -1, userInfo: nil))
        }
    }
    
    override func setData(_ documentData: [String : Any], merge: Bool, completion: ((Error?) -> Void)? = nil) {
        if(merge) {
            documentData.forEach { (k,v) in exposedData[k] = v }
        } else {
            exposedData = documentData
        }
        completion?(nil)
    }
    
    // THANK YOU STACK OVERFLOW: https://stackoverflow.com/a/47272501
    init(workaround _: Void = ()) {}
}

class MockDocumentSnapshot : DocumentSnapshot {
    var exposedData = [String: Any]()
    let _documentID = UUID().uuidString
    override var documentID: String {
        get {
            return _documentID
        }
    }

    override func data() -> [String : Any]? {
        return exposedData
    }
    
    // THANK YOU STACK OVERFLOW: https://stackoverflow.com/a/47272501
    init(workaround _: Void = ()) {}
    
    init(data: [String: Any]){
        exposedData = data
    }
}
