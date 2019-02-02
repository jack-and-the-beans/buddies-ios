//
//  UnderlinedMultiLineTextView.swift
//  Buddies
//
//  Created by Grant Yurisic on 2/2/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

class UnderlinedMultiLineTextView: UITextView, UITextViewDelegate {

    let border : CALayer
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    required init?(coder aDecoder: NSCoder) {
        border = CALayer()
        super.init(coder: aDecoder)
        
        delegate = self
        //initBorder()
    }
    
    required override init(frame: CGRect, textContainer: NSTextContainer?) {
        border = CALayer()
        super.init(frame: frame, textContainer: textContainer)
        delegate = self
        //initBorder()
    }
    
    func initBorder(){

        self.textContainer.heightTracksTextView = true
        let width = CGFloat(2.0)
        border.borderColor = ControlColors.fieldBorder.cgColor
        border.frame = CGRect(
            x: 0,
            y: self.frame.size.height-width,
            width: self.frame.size.width + self.frame.size.height,
            height: self.frame.size.height
        )
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if border.borderColor == ControlColors.fieldBorder.cgColor {
            textView.text = nil
            textView.textColor = UIColor.black
            border.borderColor = ControlColors.fieldBorderFocused.cgColor
        }
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        //self.layer.
        //initBorder()
    }
   
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            textView.text = "About you..."
            textView.textColor = UIColor.lightGray
            border.borderColor = ControlColors.fieldBorder.cgColor
        }

    }
    

}
