//
//  FirebaseMock.swift
//  BuddiesTests
//
//  Created by Luke Meier on 2/4/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import Firebase

class TestCollectionReference : CollectionReference {
    var documents = [String: TestDocumentReference]()
    
    override func document(_ documentPath: String) -> DocumentReference {
        if let document = documents[documentPath] {
            return document
        } else {
            let doc = TestDocumentReference()
            documents[documentPath] = doc
            return doc
        }
    }
    // THANK YOU STACK OVERFLOW: https://stackoverflow.com/a/47272501
    init(workaround _: Void = ()) {}
}

class TestDocumentReference : DocumentReference {
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
