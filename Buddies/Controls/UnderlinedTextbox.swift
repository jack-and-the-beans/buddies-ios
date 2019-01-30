//
//  UnderlinedTextbox.swift
//  Buddies
//
//  Created by Jake Thurman on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

class UnderlinedTextbox: UITextField, UITextFieldDelegate {
    let border: CALayer
    
    required init?(coder aDecoder: NSCoder) {
        border = CALayer()
        super.init(coder: aDecoder)
        
        delegate = self
        initBorder()
    }
    required override init(frame: CGRect) {
        border = CALayer()
        super.init(frame: frame)

        delegate = self
        initBorder()
    }
    
    func initBorder(){
        self.borderStyle = .none
        
        let width = CGFloat(2.0)
        border.borderColor = ControlColors.fieldBorder.cgColor
        border.frame = CGRect(
            x: 0,
            y: self.frame.size.height-width,
            width: self.frame.size.width,
            height: self.frame.size.height
        )
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        border.borderColor = ControlColors.fieldBorderFocused.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        border.borderColor = ControlColors.fieldBorder.cgColor
    }
}
