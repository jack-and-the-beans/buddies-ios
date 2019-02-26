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
        
        let guide = superview.safeAreaLayoutGuide
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: guide.topAnchor, constant: 0).isActive = true
        self.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 0).isActive = true
        self.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 0).isActive = true
        if (shouldConstraintBottom) {
            self.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: 0).isActive = true
        }
    }
    
    func addBottomBorderWithColor(color: UIColor, thisThicc: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - thisThicc, width: self.frame.size.width, height: thisThicc)
        self.layer.addSublayer(border)
    }

}
