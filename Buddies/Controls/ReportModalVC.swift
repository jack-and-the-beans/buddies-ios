//
//  ViewController.swift
//  Buddies
//
//  Created by Luke Meier on 3/29/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

class ReportModalVC: UIViewController {
    
    var userId: UserId? = nil
    var activityId: ActivityId? = nil
    

    @IBOutlet var textView: UITextView!
    
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    @IBOutlet weak var reportButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBAction func report(_ sender: Any) {
        let text: String = textView.text
        
        if let userId = userId {
            FirestoreManager.reportUser(userId, reportMessage: text)
        } else if let activityId = activityId {
            FirestoreManager.reportActivity(activityId, reportMessage: text)
        }
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reportButton.tintColor = Theme.bad
        cancelButton.tintColor = Theme.theme
    }
    
}
