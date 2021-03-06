//
//  FAB.swift
//  Buddies
//
//  Created by Jake Thurman on 2/2/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//
//FAB is a floating action button with a "+" icon that sits
//in the bottom right corner of the screen. Tapping it takes
//the user to the Create Activity screen.
import UIKit
import MaterialComponents.MaterialButtons

class FAB {
    let button: MDCFloatingButton
    let vc: UIViewController
    
    init(for vc: UIViewController) {
        self.vc = vc
        self.button = MDCFloatingButton()
        self.button.accessibilityIdentifier = "FAB"
    }
    
    func renderCreateActivityFab() {
        // Wire listener
        button.addTarget(self, action: #selector(self.onCreateActivityFabTapped), for: .touchUpInside)
        
        // Design
        let plusImage = UIImage(named: "plus")
        button.setImage(plusImage, for: .normal)
        button.setBackgroundColor(Theme.theme)
        button.setShadowColor(UIColor.black.withAlphaComponent(0.4), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.zPosition = 2000

        // Render
        button.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        vc.view.addSubview(button)
        
        // Position it!
        let guide = vc.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.bottomAnchor.constraint(equalToSystemSpacingBelow: button.bottomAnchor, multiplier: 2),
            guide.rightAnchor.constraint(equalToSystemSpacingAfter: button.rightAnchor, multiplier: 2)
        ])
    }

    var _createActivityPresentedHook: (() -> Void)?
    @objc func onCreateActivityFabTapped() {
        let createView = BuddiesStoryboard.CreateActivity.viewController()
        vc.present(createView, animated: true, completion: _createActivityPresentedHook)
    }
}
