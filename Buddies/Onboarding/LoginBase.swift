//
//  LoginBase.swift
//  Buddies
//
//  Created by Jake Thurman on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import Firebase

class LoginBase: UIViewController {
    var initEmailText: String?
    var initPasswordText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupHideKeyboardOnTap()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func getTopField() -> UITextField {
        fatalError("Subclasses need to implement the `getBottomField()` method.")
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if (view.frame.origin.y == 0) {
                let field = getTopField().frame
                view.frame.origin.y -= min(
                    field.origin.y - 20, // 20px top padding
                    keyboardSize.height
                )
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    func showMessagePrompt(_ msg: String) {
        let alertController = UIAlertController(title: "Login Error", message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Lazy helper
    var _authHandler: AuthHandler?
    func getAuthHandler() -> AuthHandler {
        if _authHandler == nil {
            _authHandler = AuthHandler(auth: Auth.auth())
        }
        return _authHandler!
    }
}
