//
//  UIView.swift
//  Buddies
//
//  Created by Noah Allen on 2/20/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

// THANKS! https://stackoverflow.com/a/32824659
extension UIView {
    
    // Adds constraints to this `UIView` instances `superview` object to make sure this always has the same size as the superview.
    // Please note that this has no effect if its `superview` is `nil` – add this `UIView` instance as a subview before calling this.
    func bindFrameToSuperviewBounds(shouldConstraintBottom: Bool = true) {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0).isActive = true
        if (shouldConstraintBottom) {
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        }
    }
}
