//
//  File.swift
//  Buddies
//
//  Created by Jake Thurman on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons

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
    
    func renderCreateActivityFab() {
        let button = MDCFloatingButton()
        
        // Wire listener
        button.addTarget(self, action: #selector(self.onCreateActivityFabTapped), for: .touchUpInside)
        
        // Design
        let plusImage = UIImage(named: "plus")
        button.setImage(plusImage, for: .normal)
        button.setBackgroundColor(ControlColors.themeAlt)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.zPosition = 1000
        
        // Render
        button.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        self.view.addSubview(button)
        
        // Position it!
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.bottomAnchor.constraint(equalToSystemSpacingBelow: button.bottomAnchor, multiplier: 1),
            guide.rightAnchor.constraint(equalToSystemSpacingAfter: button.rightAnchor, multiplier: 1)
            ])
    }
    
    @objc func onCreateActivityFabTapped() {
        let view = BuddiesStoryboard.CreateActivity.viewController()
        self.present(view, animated: true)
    }
}
