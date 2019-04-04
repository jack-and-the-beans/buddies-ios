//
//  ViewController.swift
//  Buddies
//
//  Created by Luke Meier on 3/29/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import Toast_Swift

class ReportModalVC: UIViewController, UITextViewDelegate {
    
    var userId: UserId? = nil
    var activityId: ActivityId? = nil
    var name: String? = nil
    let placeholderText = "Tell us a little about what went wrong..."
    
    var isUser: Bool { get { return userId != nil }}
    
    @IBOutlet weak var warningText: UILabel!
    
    var pronoun: String {
        get { return isUser ? "them" : "it" }
    }
    
    var type: String {
        get { return isUser ? "user" : "activity" }
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
        
        let tabBar = self.presentingViewController as? UITabBarController
        let srcNav = tabBar?.selectedViewController as? UINavigationController
        
        self.dismiss(animated: true){
            srcNav?.popToRootViewController(animated: true)
            if let userId = self.userId {
                FirestoreManager.reportUser(userId, reportMessage: text, completion: self.displayToast(on: srcNav?.view))
            } else if let activityId = self.activityId {
                FirestoreManager.reportActivity(activityId, reportMessage: text, completion: self.displayToast(on: srcNav?.view))
            }
        }
    }
    
    func displayToast(on view: UIView?) -> (Error?)->(){
        return { err in
            var text = ""
            if let _ = err {
                text = "Failed to report \(self.type)"
            } else {
                text = "Successfully reported \(self.type)"
            }
            
            view?.makeToast(text, duration: 2.0, position: .bottom)
        }
        
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
        
        navItem.title = "Report \(type.capitalized)"
        
        //Quotes if mentioning an activity
        let quote = isUser ? "" : "\""
        let nameText = "\(quote)\(name ?? "this")\(quote)"
        let blockInfoText = isUser ? " You'll be removed from all activities you share, and you won't be able to see activities they're in." : ""
        warningText.text = "By reporting \(nameText), you block \(pronoun).\(blockInfoText)"
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
