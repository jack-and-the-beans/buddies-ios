//
//  BuddyButton.swift
//  Buddies
//
//  Created by Noah Allen on 3/20/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

@IBDesignable open class BuddyButton: UIButton {
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.styleMe()
    }
    
    public init(type buttonType: UIButton.ButtonType) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        translatesAutoresizingMaskIntoConstraints = false
        self.styleMe()
    }
    
    static func makeButton(saying text: String, doing action: Selector, from: Any) -> BuddyButton {
        let bttn = BuddyButton(type: .system)
        bttn.setTitle(text, for: .normal)
        bttn.translatesAutoresizingMaskIntoConstraints = false
        bttn.addTarget(from, action: action, for: .touchUpInside)
        return bttn
    }

    func styleMe() {
        self.layer.cornerRadius = 10
        self.backgroundColor = ControlColors.theme
        self.titleLabel?.textColor = ControlColors.white
        self.tintColor = ControlColors.white
    }
}
