
//
//  FirestoreManager.swift
//  Buddies
//
//  Created by Luke Meier on 1/31/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import FirebaseFirestore
import FirebaseCore
import FirebaseStorage

class FirestoreManager {
    static var db: Firestore {
        get {
            return Firestore.firestore()
        }
    }
    
    //https://github.com/AssassinDev422/hallow/blob/e1b334df607a1a5cddf4f5b1eb23a88c3db7871e/Hallow/Utilities/FirebaseUtilities.swift
    static func loadAllDocuments(ofType type: String,
                                 _ callback: @escaping ([DocumentSnapshot]) -> ()) {
        db.collection(type).getDocuments { result, error in
            guard let result = result,
                error == nil else {
                    print("Error loading \(type) from Firestore: \n \(String(describing: error))")
                callback([])
                return
            }
            callback(result.documents)
        }
    }
}
