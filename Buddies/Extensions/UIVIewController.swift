//
//  File.swift
//  Buddies
//
//  Created by Jake Thurman on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

extension UIViewController {
    /// Call this once to dismiss open keyboards by tapping anywhere in the view controller
    func setupHideKeyboardOnTap() {
        self.view.addGestureRecognizer(endEditingRecognizer())
        self.navigationController?.navigationBar.addGestureRecognizer(endEditingRecognizer())
    }
    
    @objc private func endEditingRecognizer() -> UIGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing))
        tap.cancelsTouchesInView = false
        return tap
    }
}
