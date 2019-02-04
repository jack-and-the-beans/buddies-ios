//
//  FAB.swift
//  Buddies
//
//  Created by Jake Thurman on 2/2/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons

class FAB {
    let button: MDCFloatingButton
    let vc: UIViewController
    
    init(for vc: UIViewController) {
        self.vc = vc
        self.button = MDCFloatingButton()
    }
    
    func renderCreateActivityFab() {
        // Wire listener
        button.addTarget(self, action: #selector(self.onCreateActivityFabTapped), for: .touchUpInside)
        
        // Design
        let plusImage = UIImage(named: "plus")
        button.setImage(plusImage, for: .normal)
        button.setBackgroundColor(ControlColors.themeAlt)
        button.setShadowColor(UIColor.black.withAlphaComponent(0.4), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.zPosition = 1000
        
        // Render
        button.frame = CGRect(x: 0, y: 0, width: 48, height: 48)
        vc.view.addSubview(button)
        
        // Position it!
        let guide = vc.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.bottomAnchor.constraint(equalToSystemSpacingBelow: button.bottomAnchor, multiplier: 1),
            guide.rightAnchor.constraint(equalToSystemSpacingAfter: button.rightAnchor, multiplier: 1)
        ])
    }
    
    var _createActivityPresentedHook: (() -> Void)?
    @objc func onCreateActivityFabTapped() {
        let createView = BuddiesStoryboard.CreateActivity.viewController()
        vc.present(createView, animated: true, completion: _createActivityPresentedHook)
    }
}
