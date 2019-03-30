//
//  ViewController.swift
//  Buddies
//
//  Created by Luke Meier on 3/29/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

class ReportModalVC: UIViewController, UITextViewDelegate {
    
    var userId: UserId? = nil
    var activityId: ActivityId? = nil
    var name: String? = nil
    let placeholderText = "Tell us a little about what went wrong..."
    
    var forUser: Bool { get { return userId != nil }}
    
    @IBOutlet weak var warningText: UILabel!
    
    var pronoun: String {
        get { return forUser ? "them" : "it" }
    }
    
    var type: String {
        get { return forUser ? "user" : "activity" }
    }

    @IBOutlet weak var textView: UITextView!
    
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var reportButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBAction func report(_ sender: Any) {
        let text: String = textView.text
        
        guard text.count > 0,
            text != placeholderText
            else { return }
        
        if let userId = userId {
            FirestoreManager.reportUser(userId, reportMessage: text)
        } else if let activityId = activityId {
            FirestoreManager.reportActivity(activityId, reportMessage: text)
        }
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupHideKeyboardOnTap()
        
        reportButton.tintColor = Theme.bad
        cancelButton.tintColor = Theme.theme
        
        textView.delegate = self
        textView.textColor = UIColor.lightGray
        textView.text = placeholderText
        textView.layer.cornerRadius = Theme.cornerRadius
        textView.layer.borderColor = Theme.fieldBorder.cgColor
        textView.textContainerInset = Theme.textAreaInset
        textView.layer.borderWidth = Theme.textAreaBorderWidth
        
        navItem.title = forUser ? "Report User" : "Report Activity"
        
        //Quotes if mentioning an activity
        let nameText = "\(!forUser ? "\"" : "")\(name ?? "this")\(!forUser ? "\"" : "")"
        
        warningText.text = "By reporting \(nameText), you block \(pronoun)."
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        textView.layer.borderColor = Theme.fieldBorderFocused.cgColor
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholderText
            textView.textColor = UIColor.lightGray
        }
        textView.layer.borderColor = Theme.fieldBorder.cgColor
    }
    
}
