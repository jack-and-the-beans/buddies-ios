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
    
    @IBInspectable
    var selectedColor: UIColor = UIColor.white {
        didSet {
            tintColor = isSelected ? selectedColor : unselectedColor
        }
    }
    
    @IBInspectable
    var unselectedColor: UIColor = UIColor.white  {
        didSet {
            tintColor = isSelected ? selectedColor : unselectedColor
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
        setImage(selectedImg, for: .selected)
        setImage(unselectedImg, for: .normal)
        setImage(unselectedImg, for: .disabled)
        setImage(selectedImg, for: .highlighted)
        setImage(selectedImg, for: [.selected, .highlighted])
        
        addTarget(self, action: #selector(toggle), for: .touchUpInside)
    }
    
    override func title(for state: UIControl.State) -> String? {
        return nil
    }
    
    override var isSelected: Bool {
        didSet {
            tintColor = isSelected ? selectedColor : unselectedColor
        }
    }
    
    @objc func toggle() {
        isSelected = !isSelected
    }
}
