//
//  SelectButton.swift
//  Buddies
//
//  Created by Luke Meier on 2/6/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

@IBDesignable class ToggleButton: UIButton {
    
    @IBInspectable
    var toggleColor: UIColor = UIColor.blue
    
    @IBInspectable
    var size: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupImage()
        }
    }
    
    @IBInspectable
    var selectedImg: UIImage? = UIImage(named: "select_btn_on") {
        didSet {
            setupImage()
        }
    }
    
    @IBInspectable
    var unselectedImg: UIImage? = UIImage(named: "select_btn_off") {
        didSet{
            setupImage()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupImage()
    }
    
    
    func setupImage(){
        heightAnchor.constraint(equalToConstant: size.height).isActive = true
        widthAnchor.constraint(equalToConstant: size.width).isActive = true
        
        setImage(selectedImg, for: .selected)
        setImage(unselectedImg, for: .normal)
        setImage(unselectedImg, for: .disabled)
        setImage(selectedImg, for: .highlighted)
        setImage(selectedImg, for: [.selected, .highlighted])
        
        addTarget(self, action: #selector(toggled), for: .touchUpInside)
    }
    
    override func title(for state: UIControl.State) -> String? {
        return nil
    }
    
    @objc func toggled() {
        isSelected = !isSelected
    }
    
    override func titleColor(for state: UIControl.State) -> UIColor? {
        return toggleColor
    }
}
