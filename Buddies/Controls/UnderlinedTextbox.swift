//
//  UnderlinedTextbox.swift
//  Buddies
//
//  Created by Jake Thurman on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

@IBDesignable
class UnderlinedTextbox: UITextField, UITextFieldDelegate {
    let border: CALayer
    
    required init?(coder aDecoder: NSCoder) {
        border = CALayer()
        super.init(coder: aDecoder)
        
        delegate = self
    }
    required override init(frame: CGRect) {
        border = CALayer()
        super.init(frame: frame)

        delegate = self
    }
    
    override func draw(_ rect: CGRect) {
        self.borderStyle = .none
        
        border.backgroundColor = Theme.fieldBorder.cgColor
        border.frame = CGRect(
            x: 0,
            y: self.bounds.height - 2,
            width: self.bounds.size.width,
            height: self.bounds.size.height
        )
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        border.backgroundColor = Theme.fieldBorderFocused.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        border.backgroundColor = Theme.fieldBorder.cgColor
    }
}
