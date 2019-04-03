//
//  TestCreateActivity.swift
//  BuddiesUITests
//
//  Created by Luke Meier on 4/3/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest

class TestCreateActivity: BuddiesUITestCase {

    func trySuggest(shouldAlert: Bool = true, extraMsg: String = ""){
        let suggestButton = app.navigationBars["Suggest Activity"].buttons["Suggest"]
        
        XCTAssertTrue(waitForElementToAppear(suggestButton, timeout: 5), "Suggest button should exist. \(extraMsg)")
        
        suggestButton.tap()
        
        let okButton = app.alerts["Missing information"].buttons["OK"]
        
        XCTAssert(waitForElementToAppear(okButton, timeout: 5) == shouldAlert, "Alert should \(shouldAlert ? "" : "not") appear when suggesting. \(extraMsg)")
        
        if shouldAlert {
            okButton.tap()
        }
    }
    
    func testCreateActivity() {
        login()
        
        let tablesQuery = app.tables
        
        tablesQuery/*@START_MENU_TOKEN@*/.buttons["FAB"]/*[[".buttons[\"plus\"]",".buttons[\"FAB\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        trySuggest(shouldAlert: true, extraMsg: "Inititally on an empty table")
        
        let title = tablesQuery.textFields["activityTitleField"]
        title.tap()
        title.typeText("Title")
        
        trySuggest(shouldAlert: true, extraMsg: "After typing title...")
        
        let locationTextField = tablesQuery.textFields["activityLocationField"]
        locationTextField.tap()
        locationTextField.typeText("Beans")
        
        trySuggest(shouldAlert: true, extraMsg: "After writing a location...")
        
        
        let description = tablesQuery/*@START_MENU_TOKEN@*/.textViews["activityDescriptionField"]/*[[".cells.textViews[\"activityDescriptionField\"]",".textViews[\"activityDescriptionField\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        description.tap()
        
        trySuggest(shouldAlert: true, extraMsg: "After tapping description...")
        
        description.tap()
        description.typeText("Description")
        
        print(app.debugDescription)
        
        let pickTopics = tablesQuery.cells["activityPickTopics"]
        pickTopics.tap()
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.children(matching: .cell).element(boundBy: 1).buttons["uncheck circle"].tap()
    
        app.navigationBars["Pick Topics"].buttons["Done"].tap()
        
        trySuggest(shouldAlert: true, extraMsg: "After adding topics...")

        
        //Doesn't actually create one
    }

}
