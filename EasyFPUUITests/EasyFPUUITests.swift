//
//  EasyFPUUITests.swift
//  EasyFPUUITests
//
//  Created by Ulrich Rüth on 03/11/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import XCTest

final class EasyFPUUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
        
        app/*@START_MENU_TOKEN@*/.staticTexts["Füge Speisen zur Mahlzeit hinzu"]/*[[".buttons[\"Füge Speisen zur Mahlzeit hinzu\"].staticTexts[\"Füge Speisen zur Mahlzeit hinzu\"]",".staticTexts[\"Füge Speisen zur Mahlzeit hinzu\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["Chicken McNuggets"]/*[[".cells.staticTexts[\"Chicken McNuggets\"]",".staticTexts[\"Chicken McNuggets\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["6 Stück"]/*[[".cells.staticTexts[\"6 Stück\"]",".staticTexts[\"6 Stück\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let hinzufGenButton = app.buttons["Hinzufügen"]
        hinzufGenButton.tap()
        
        let element = collectionViewsQuery.children(matching: .cell).element(boundBy: 7).children(matching: .other).element(boundBy: 1).children(matching: .other).element
        element.swipeUp()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["Ketchup McDonalds"]/*[[".cells.staticTexts[\"Ketchup McDonalds\"]",".staticTexts[\"Ketchup McDonalds\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["2 Tütchen"]/*[[".cells.staticTexts[\"2 Tütchen\"]",".staticTexts[\"2 Tütchen\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        hinzufGenButton.tap()
        
        let element2 = collectionViewsQuery.children(matching: .cell).element(boundBy: 9).children(matching: .other).element(boundBy: 1).children(matching: .other).element
        element2.swipeUp()
        element2.swipeUp()
        
        let element3 = collectionViewsQuery.children(matching: .cell).element(boundBy: 8).children(matching: .other).element(boundBy: 1).children(matching: .other).element
        element3.swipeUp()
        element3.swipeUp()
        element3.swipeUp()
        element.swipeUp()
        element3.swipeUp()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["Semmel weiß"]/*[[".cells.staticTexts[\"Semmel weiß\"]",".staticTexts[\"Semmel weiß\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        element3.swipeUp()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["Süßer Senf (Händlmaier)"]/*[[".cells.staticTexts[\"Süßer Senf (Händlmaier)\"]",".staticTexts[\"Süßer Senf (Händlmaier)\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        element3.swipeUp()
        app.navigationBars["Meine Speisen"]/*@START_MENU_TOKEN@*/.buttons["checkmark.circle.fill"]/*[[".otherElements[\"Ausgewählt\"]",".buttons[\"Ausgewählt\"]",".buttons[\"checkmark.circle.fill\"]",".otherElements[\"checkmark.circle.fill\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["SPEISEN"]/*[[".cells.staticTexts[\"SPEISEN\"]",".staticTexts[\"SPEISEN\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["Details"]/*[[".cells",".buttons[\"Details\"].staticTexts[\"Details\"]",".staticTexts[\"Details\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["Meine Mahlzeit"].buttons["Schließen"].tap()
        
        let mahlzeitBerechnenNavigationBar = app.navigationBars["Mahlzeit berechnen"]
        mahlzeitBerechnenNavigationBar/*@START_MENU_TOKEN@*/.buttons["square.and.arrow.up"]/*[[".otherElements[\"Teilen\"]",".buttons[\"Teilen\"]",".buttons[\"square.and.arrow.up\"]",".otherElements[\"square.and.arrow.up\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.staticTexts["Nach Apple Health exportieren"]/*[[".buttons[\"Nach Apple Health exportieren\"].staticTexts[\"Nach Apple Health exportieren\"]",".staticTexts[\"Nach Apple Health exportieren\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.sheets["Achtung!"].scrollViews.otherElements.buttons["Trotzdem exportieren"].tap()
        app.alerts["Hinweis"].scrollViews.otherElements.buttons["OK"].tap()
        app.navigationBars["Health-Export"]/*@START_MENU_TOKEN@*/.buttons["xmark.circle.fill"]/*[[".otherElements[\"Schließen\"]",".buttons[\"Schließen\"]",".buttons[\"xmark.circle.fill\"]",".otherElements[\"xmark.circle.fill\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        mahlzeitBerechnenNavigationBar/*@START_MENU_TOKEN@*/.buttons["xmark.circle"]/*[[".otherElements[\"Schließen\"]",".buttons[\"Schließen\"]",".buttons[\"xmark.circle\"]",".otherElements[\"xmark.circle\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
                
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
