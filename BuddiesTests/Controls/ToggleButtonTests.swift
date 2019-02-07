//
//  ToggleButtonTests.swift
//  BuddiesTests
//
//  Created by Luke Meier on 2/7/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest

@testable import Buddies

class ToggleButtonTests: XCTestCase {

    var frame: CGRect!
    
    override func setUp() {
        frame = CGRect(x: 100, y: 100, width: 100, height: 100)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDefaultButtonToggles() {
        let button = ToggleButton(frame: frame)
        
        XCTAssert(!button.isSelected)
        
        button.sendActions(for: .touchUpInside)
        
        XCTAssert(button.isSelected)
        
        button.sendActions(for: .touchUpInside)
        
        XCTAssert(!button.isSelected)
    }

    func testSetConstraints() {
        let button = ToggleButton(frame: frame)
        let constraints = button.constraints
        
        XCTAssert(constraints.count == 2)
        
        button.size = CGSize(width: 100, height: 100)
        
        XCTAssert(constraints.count == 2)
        XCTAssert(constraints != button.constraints)
    }
    
    func testSetImages(){
        let button = ToggleButton(frame: frame)
        let selectedImage = button.image(for: .selected)
        let normalImage = button.image(for: .normal)
        
        // Verify that images are passed by reference, so this test is meaningful
        XCTAssert(selectedImage == button.image(for: .selected))
        XCTAssert(normalImage == button.image(for: .normal))
        
        button.selectedImg = UIImage()
        button.unselectedImg = UIImage()
        
        let newSelectedImage = button.image(for: .selected)
        let newNormalImage = button.image(for: .normal)
        
        XCTAssert(selectedImage != newSelectedImage)
        XCTAssert(normalImage != newNormalImage)
    }
    
    func testNoTitle(){
        let button = ToggleButton(frame: frame)
        
        XCTAssert(button.title(for: .selected) == nil)
        XCTAssert(button.title(for: .highlighted) == nil)
        XCTAssert(button.title(for: .normal) == nil)
        XCTAssert(button.title(for: .disabled) == nil)
    }
    
    func testSetColor(){
        let button = ToggleButton(frame: frame)
        
        button.toggleColor = UIColor.red
        
        XCTAssert(button.titleColor(for: .selected) == UIColor.red)
        XCTAssert(button.titleColor(for: .highlighted) == UIColor.red)
        XCTAssert(button.titleColor(for: .normal) == UIColor.red)
        XCTAssert(button.titleColor(for: .disabled) == UIColor.red)
    }
}
