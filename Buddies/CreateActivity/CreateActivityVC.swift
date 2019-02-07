//
//  CreateActivityVC.swift
//  Buddies
//
//  Created by Grant Yurisic on 2/6/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import Firebase

class CreateActivityVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            titleField.becomeFirstResponder()
        }
        else if indexPath.section == 1
        {
            locationField.becomeFirstResponder()
        }
    }
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var titleField: UITextField!
    
    @IBOutlet weak var locationField: UITextField!
    
    var _dismissHook: (() -> Void)?
    
    @IBAction func cancelCreateActivity(_ segue: UIStoryboardSegue) {
         dismiss(animated: true, completion: _dismissHook)
    }
    
    @IBAction func finishCreateActivity(_ segue: UIStoryboardSegue) {
        
        guard let title = titleField.text else {return}
        guard let description = descriptionTextView.text else {return}
        saveActivityToFirestore(title: title, description: description)
        dismiss(animated: true, completion: _dismissHook)
    }

    func saveActivityToFirestore(
        title: String = "Title",
        description: String = "Description",
        user: UserInfo? = Auth.auth().currentUser,
        collection: CollectionReference = Firestore.firestore().collection("activities"),
        location: GeoPoint = GeoPoint(latitude: 0, longitude: 0),
        startTime: Date = Date(),
        endTime: Date = Date(),
        topicIDs: [String] = []){
        
        guard let uid = user?.uid else {return}
        
        collection.addDocument(data: [
            "title": title,
            "owner_id": uid,
            "description" : description,
            "date_created": Date(),
            "location": location,
            "start_time": startTime,
            "end_time": endTime,
            "topic_ids": topicIDs,
            "members": [uid]
        ])
    }
}
