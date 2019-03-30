//
//  Theme.swift
//  Buddies
//
//  Created by Jake Thurman on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

class Theme {
    // Colors
    static let fieldBorder = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1.0)
    static let fieldBorderFocused = Theme.themeAlt.withAlphaComponent(0.8)
    static let theme =  UIColor(red: 69/255, green: 68/255, blue: 184/255, alpha: 1.0)
    static let themeAlt =  UIColor(red: 126/255, green: 92/255, blue: 171/255, alpha: 1.0)
    static let white = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
    static let bad = UIColor.red
    static let textAreaInset = UIEdgeInsets(top: 12 ,left: 7, bottom: 12, right: 7)
    static let textAreaBorderWidth: CGFloat = 1.5
    
    // Other constants
    static let cornerRadius: CGFloat = 10.0
}
