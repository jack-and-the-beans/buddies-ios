
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
import FirebaseAuth

class FirestoreManager {
    var db: Firestore {
        get {
            return Firestore.firestore()
        }
    }

    static let shared = FirestoreManager()
    
    //https://github.com/AssassinDev422/hallow/blob/e1b334df607a1a5cddf4f5b1eb23a88c3db7871e/Hallow/Utilities/FirebaseUtilities.swift
    func loadAllDocuments(ofType type: String,
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
    
    static func getUserAssociatedActivities( userID: String,
                                             _ callback: @escaping ([[Activity]]) -> ()) {
        Firestore.firestore().collection("activities").whereField("members", arrayContains: userID).getDocuments { result, error in
            guard let result = result,
                error == nil else {
                    print("Error loading \(userID) from Firestore: \n \(String(describing: error))")
                    callback([[],[],[]])
                    return
            }
            
            var created = [Activity]()
            var joined = [Activity]()
            var previous = [Activity]()
            
            for document in result.documents{
                
                guard let activity = Activity.from(snap: document, with: nil) else { continue }
                
                let endTime  = document.get("end_time") as! Timestamp
                
                if(endTime.dateValue() < Date())
                {
                    previous.append(activity)
                }
                else if(document.get("owner_id") as! String == userID)
                {
                    created.append(activity)
                }
                else
                {
                    joined.append(activity)
                }
                
                
            }
            
            callback([created, joined, previous])
        }
    }
    
    static func reportActivity(_ activityId: String, reportMessage: String, curUid: String? = Auth.auth().currentUser?.uid) {
        guard let uid = curUid else { return }
        Firestore.firestore().collection("activity_report").addDocument(data: [
            "report_by_id": uid,
            "reported_activity_id": activityId,
            "message": reportMessage,
            "timestamp": Timestamp(date: Date())
        ])
    }
    
    static func deleteActivity(_ activity: Activity, curUid: String? = Auth.auth().currentUser?.uid) {
        guard let uid = curUid else { return }
        if activity.getMemberStatus(of: uid) == .owner {
            Firestore.firestore().collection("activities").document(activity.activityId).delete()
        }
    }
}
