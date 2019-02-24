//
//  FirebaseMock.swift
//  BuddiesTests
//
//  Created by Luke Meier on 2/4/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import XCTest

class MockExistingUser : NSObject, UserInfo {
    var providerID: String = "test"
    
    var displayName: String? = "test"
    
    var photoURL: URL? = nil
    
    var email: String? = "test"
    
    var phoneNumber: String? = "test"
    
    var uid: String = "test_uid"
    
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
    var docId: String? = nil
    var listeners = [FIRDocumentSnapshotBlock]()
    
    override func updateData(_ fields: [AnyHashable : Any], completion: ((Error?) -> Void)? = nil) {
        if let data = fields as? [String: Any] {
            //Update exposedData
            data.forEach { (k,v) in exposedData[k] = v }
            completion?(nil)
            
            listeners.forEach { getDocument(completion: $0) }
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
        listeners.forEach { getDocument(completion: $0) }
    }
    
    override func getDocument(completion: @escaping FIRDocumentSnapshotBlock) {
        let snap = MockDocumentSnapshot(data: exposedData, docId: docId)
        completion(snap, nil)
    }
    
    override func addSnapshotListener(_ listener: @escaping FIRDocumentSnapshotBlock) -> ListenerRegistration {
        listeners.append(listener)
        getDocument(completion: listener)
        return ListenerCanceler()
    }
    
    // THANK YOU STACK OVERFLOW: https://stackoverflow.com/a/47272501
    init(docId: String? = nil) {
        self.docId = docId
    }
    
    class ListenerCanceler : NSObject, ListenerRegistration {
        var isCleaned = false
        deinit {
            XCTAssert(isCleaned, "Failed to cleanup :(")
        }
        
        func remove() {
            isCleaned = true
        }
    }
}

class MockDocumentSnapshot : DocumentSnapshot {
    var exposedData = [String: Any]()
    let _documentID: String
    override var documentID: String {
        get {
            return _documentID
        }
    }
    
    override var exists: Bool {
        get { return true }
    }

    override func data() -> [String : Any]? {
        return exposedData
    }
    
    // THANK YOU STACK OVERFLOW: https://stackoverflow.com/a/47272501
    init(workaround _: Void = ()) {
        _documentID = UUID().uuidString
    }
    
    init(data: [String: Any], docId: String? = nil){
        exposedData = data
        _documentID = docId ?? UUID().uuidString
    }
}
