//
//  EasyFPUUITests.swift
//  EasyFPUUITests
//
//  Created by Ulrich Rüth on 03/11/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import XCTest

final class EasyFPUUITests: XCTestCase {
    var app: XCUIApplication!

    @MainActor
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        // Launch app
        app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app = nil
    }
    
    @MainActor
    func testCalculateMeal() throws {
        snapshot("01CalculateMeal")
        app.buttons["MainView.CalculateMeal.AddProductsButton"].tap()
        
        snapshot("02ListFoodSelection")
        let collectionViewsQuery = app.collectionViews
        
        collectionViewsQuery/*@START_MENU_TOKEN@*/.images["MainView.CalculateMeal.AddProductToMeal.Chicken Mc.SelectFoodItemButton"]/*[[".cells.images[\"MainView.CalculateMeal.AddProductToMeal.Chicken Mc.SelectFoodItemButton\"]",".images[\"MainView.CalculateMeal.AddProductToMeal.Chicken Mc.SelectFoodItemButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["MainView.CalculateMeal.AddProductToMeal.Chicken Mc.SelectFoodItems.TAmount110.TypicalAmountComment"]/*[[".cells",".staticTexts[\"6 Stück\"]",".staticTexts[\"MainView.CalculateMeal.AddProductToMeal.Chicken Mc.SelectFoodItems.TAmount110.TypicalAmountComment\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        snapshot("03SelectAmount")
        app/*@START_MENU_TOKEN@*/.buttons["MainView.CalculateMeal.AddProductToMeal.Chicken Mc.SelectFoodItems.AddButton"]/*[[".buttons[\"Hinzufügen\"]",".buttons[\"MainView.CalculateMeal.AddProductToMeal.Chicken Mc.SelectFoodItems.AddButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["MainView.CalculateMeal.AddProductToMeal.Alpenzwerg.FoodItemNameLabel"]/*[[".cells",".staticTexts[\"Alpenzwerg Bioschokomilch (Berchtesgadener Land)\"]",".staticTexts[\"MainView.CalculateMeal.AddProductToMeal.Alpenzwerg.FoodItemNameLabel\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.swipeDown()
        
        snapshot("04SearchFood")
        
        collectionViewsQuery.images["MainView.CalculateMeal.AddProductToMeal.Chips.SelectFoodItemButton"].tap()
        collectionViewsQuery.staticTexts["MainView.CalculateMeal.AddProductToMeal.Chips.SelectFoodItems.TAmount30.TypicalAmountComment"].tap()
        app.buttons["MainView.CalculateMeal.AddProductToMeal.Chips.SelectFoodItems.AddButton"].tap()
        
        app/*@START_MENU_TOKEN@*/.buttons["MainView.CalculateMeal.AddProductToMeal.SaveButton"]/*[[".otherElements[\"Ausgewählt\"]",".buttons[\"Ausgewählt\"]",".buttons[\"MainView.CalculateMeal.AddProductToMeal.SaveButton\"]",".otherElements[\"MainView.CalculateMeal.AddProductToMeal.SaveButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        snapshot("05CalculateMealOverview")
        
        app.buttons["MainView.CalculateMeal.EditProductsButton"].swipeUp()
        collectionViewsQuery.buttons["MainView.CalculateMeal.MealDetailsButton"].tap()
        snapshot("06CalculateMealDetails")
        app/*@START_MENU_TOKEN@*/.buttons["MainView.CalculateMeal.MealDetails.CloseButton"]/*[[".buttons[\"Schließen\"]",".buttons[\"MainView.CalculateMeal.MealDetails.CloseButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        app/*@START_MENU_TOKEN@*/.buttons["MainView.CalculateMeal.ExportButton"]/*[[".otherElements[\"Teilen\"]",".buttons[\"Teilen\"]",".buttons[\"MainView.CalculateMeal.ExportButton\"]",".otherElements[\"MainView.CalculateMeal.ExportButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let mainviewCalculatemealExportmealtohealthMealdelaystepperIncrementButton = app.steppers["MainView.CalculateMeal.ExportMealToHealth.MealDelayStepper"].buttons["MainView.CalculateMeal.ExportMealToHealth.MealDelayStepper-Increment"]
        mainviewCalculatemealExportmealtohealthMealdelaystepperIncrementButton.tap()
        mainviewCalculatemealExportmealtohealthMealdelaystepperIncrementButton.tap()
        snapshot("07AppleHealthExportOverview")
        
        app/*@START_MENU_TOKEN@*/.buttons["MainView.CalculateMeal.ExportMealToHealth.CloseButton"]/*[[".otherElements[\"Schließen\"]",".buttons[\"Schließen\"]",".buttons[\"MainView.CalculateMeal.ExportMealToHealth.CloseButton\"]",".otherElements[\"MainView.CalculateMeal.ExportMealToHealth.CloseButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["MainView.CalculateMeal.ClearButton"]/*[[".otherElements[\"Schließen\"]",".buttons[\"Schließen\"]",".buttons[\"MainView.CalculateMeal.ClearButton\"]",".otherElements[\"MainView.CalculateMeal.ClearButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
                
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
