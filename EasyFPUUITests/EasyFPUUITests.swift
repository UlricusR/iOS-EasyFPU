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
        collectionViewsQuery.staticTexts["MainView.CalculateMeal.SelectFoodItem.TAmount109.TypicalAmountComment"].tap()
        
        snapshot("03SelectAmount")
        
        app.buttons["MainView.CalculateMeal.SelectFoodItem.AddButton"].tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.images["MainView.CalculateMeal.AddProductToMeal.Chips.SelectFoodItemButton"]/*[[".cells.images[\"MainView.CalculateMeal.AddProductToMeal.Chips.SelectFoodItemButton\"]",".images[\"MainView.CalculateMeal.AddProductToMeal.Chips.SelectFoodItemButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery.staticTexts["MainView.CalculateMeal.SelectFoodItem.TAmount30.TypicalAmountComment"].tap()
        app.buttons["MainView.CalculateMeal.SelectFoodItem.AddButton"].tap()
        
        app.navigationBars.buttons.element(boundBy: 0).tap() // The back button
        snapshot("04CalculateMealOverview")
        
        collectionViewsQuery.children(matching: .cell).element(boundBy: 3).children(matching: .other).element(boundBy: 1).children(matching: .other).element.swipeUp()
        app.buttons["MainView.CalculateMeal.MealDetailsButton"].tap()
        snapshot("05CalculateMealDetails")
        app.navigationBars.buttons.element(boundBy: 0).tap() // The back button
        
        app/*@START_MENU_TOKEN@*/.buttons["MainView.CalculateMeal.ExportButton"]/*[[".otherElements[\"Teilen\"]",".buttons[\"Teilen\"]",".buttons[\"MainView.CalculateMeal.ExportButton\"]",".otherElements[\"MainView.CalculateMeal.ExportButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let mainviewCalculatemealExportmealtohealthMealdelaystepperIncrementButton = app.steppers["MainView.CalculateMeal.ExportMealToHealth.MealDelayStepper"].buttons["MainView.CalculateMeal.ExportMealToHealth.MealDelayStepper-Increment"]
        mainviewCalculatemealExportmealtohealthMealdelaystepperIncrementButton.tap()
        mainviewCalculatemealExportmealtohealthMealdelaystepperIncrementButton.tap()
        snapshot("06AppleHealthExportOverview")
        
        app.navigationBars.buttons.element(boundBy: 0).tap() // The back button
        app/*@START_MENU_TOKEN@*/.buttons["MainView.CalculateMeal.ClearButton"]/*[[".otherElements[\"Schließen\"]",".buttons[\"Schließen\"]",".buttons[\"MainView.CalculateMeal.ClearButton\"]",".otherElements[\"MainView.CalculateMeal.ClearButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
                
    }
    
    @MainActor
    func testCookAndBake() throws {
        app/*@START_MENU_TOKEN@*/.buttons["frying.pan"]/*[[".buttons[\"Kochen & Backen\"]",".buttons[\"frying.pan\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        snapshot("10RecipeList")
        
        app/*@START_MENU_TOKEN@*/.buttons["MainView.CookAndBake.AddRecipeButton"]/*[[".otherElements[\"Hinzufügen\"]",".buttons[\"Hinzufügen\"]",".buttons[\"MainView.CookAndBake.AddRecipeButton\"]",".otherElements[\"MainView.CookAndBake.AddRecipeButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        snapshot("11AddIngredients")
        
        app.buttons["MainView.CookAndBake.CreateRecipe.AddIngredientsButton"].tap()
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.images["MainView.CookAndBake.SelectIngredients.Butter.SelectFoodItemButton"].tap()
        collectionViewsQuery.staticTexts["MainView.CookAndBake.SelectFoodItem.TAmount125.TypicalAmountComment"].tap()
        app.buttons["MainView.CookAndBake.SelectFoodItem.AddButton"].tap()
        collectionViewsQuery.images["MainView.CookAndBake.SelectIngredients.Eier.SelectFoodItemButton"].tap()
        collectionViewsQuery.staticTexts["MainView.CookAndBake.SelectFoodItem.TAmount110.TypicalAmountComment"].tap()
        
        snapshot("12SelectIngredient")
        
        app.buttons["MainView.CookAndBake.SelectFoodItem.AddButton"].tap()
        
        snapshot("13IngredientsSelected")
        
        app.navigationBars.buttons.element(boundBy: 0).tap() // The back button
        let mainviewCookandbakeEditrecipeNumberofportionsstepperIncrementButton = collectionViewsQuery.steppers["MainView.CookAndBake.CreateRecipe.NumberOfPortionsStepper"].buttons["MainView.CookAndBake.CreateRecipe.NumberOfPortionsStepper-Increment"]
        mainviewCookandbakeEditrecipeNumberofportionsstepperIncrementButton.tap()
        mainviewCookandbakeEditrecipeNumberofportionsstepperIncrementButton.tap()
        mainviewCookandbakeEditrecipeNumberofportionsstepperIncrementButton.tap()
        mainviewCookandbakeEditrecipeNumberofportionsstepperIncrementButton.tap()
        mainviewCookandbakeEditrecipeNumberofportionsstepperIncrementButton.tap()
        
        snapshot("14RecipeFinished")
        
        app.buttons["MainView.CookAndBake.CreateRecipe.SaveButton"].tap()
        
        snapshot("15RecipeInList")
    }
    
    @MainActor
    func testSearchForProduct() throws {
        app.buttons["birthday.cake"].tap()
        
        snapshot("20DishesList")
        
        app/*@START_MENU_TOKEN@*/.buttons["MainView.MaintainProducts.AddFoodItemButton"]/*[[".otherElements[\"Hinzufügen\"]",".buttons[\"Hinzufügen\"]",".buttons[\"MainView.MaintainProducts.AddFoodItemButton\"]",".otherElements[\"MainView.MaintainProducts.AddFoodItemButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        snapshot("21AddFoodItemEmpty")
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.textFields["MainView.MaintainProducts.AddFoodItem.AddFoodItem.NameValue"].tap()
        collectionViewsQuery.textFields["MainView.MaintainProducts.AddFoodItem.AddFoodItem.NameValue"].typeText("Chicken McNuggets")
        
        snapshot("22AddFoodItemWithName")
        
        collectionViewsQuery.buttons["MainView.MaintainProducts.AddFoodItem.AddFoodItem.SearchButton"].tap()
        sleep(10)
        
        snapshot("23SearchResults")
        
        collectionViewsQuery.buttons["MainView.MaintainProducts.SearchFood.6 Chicken .ProductName"].tap()
        
        snapshot("24SearchResultDetails")
        
        app.buttons["MainView.MaintainProducts.ProductDetails.SelectButton"].tap()
        
        snapshot("25AddFoodItemFilled")
    }
    
    @MainActor
    func testEditIngredients() throws {
        app/*@START_MENU_TOKEN@*/.buttons["frying.pan"]/*[[".buttons[\"Kochen & Backen\"]",".buttons[\"frying.pan\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeLeft()
        app.buttons["carrot"].tap()
        
        snapshot("30IngredientsList")
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.staticTexts["MainView.MaintainIngredients.Backhefe (.FoodItemNameLabel"].swipeLeft()
        
        snapshot("31FoodListSwipeLeft")
        
        collectionViewsQuery.buttons["MainView.MaintainIngredients.Backhefe (.EditButton"].tap()
        collectionViewsQuery.textFields["MainView.MaintainIngredients.EditFoodItem.EditFoodItem.EditTypicalAmountValue"].tap()
        collectionViewsQuery.textFields["MainView.MaintainIngredients.EditFoodItem.EditFoodItem.EditTypicalAmountValue"].typeText("42")
        
        let mainviewMaintainingredientsBackhefeEditfooditemEdittypicalamountcommentTextField = collectionViewsQuery.textFields["MainView.MaintainIngredients.EditFoodItem.EditFoodItem.EditTypicalAmountComment"]
        mainviewMaintainingredientsBackhefeEditfooditemEdittypicalamountcommentTextField.tap()
        mainviewMaintainingredientsBackhefeEditfooditemEdittypicalamountcommentTextField.typeText("1 Würfel")
        
        snapshot("32TypicalAmountEntered")
        
        collectionViewsQuery.buttons["MainView.MaintainIngredients.EditFoodItem.EditFoodItem.AddTypicalAmountButton"].tap()
        
        snapshot("33TypicalAmountAdded")
        
        app.buttons["MainView.MaintainIngredients.EditFoodItem.EditFoodItem.SaveButton"].tap()
        
        snapshot("34ConfirmChangeRecipes")
    }
    
    @MainActor
    func testSettings() async throws {
        app/*@START_MENU_TOKEN@*/.buttons["frying.pan"]/*[[".buttons[\"Kochen & Backen\"]",".buttons[\"frying.pan\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeLeft()
        app/*@START_MENU_TOKEN@*/.buttons["gear"]/*[[".buttons[\"Einstellungen\"]",".buttons[\"gear\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        snapshot("40SettingsMenu")
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["MainView.Settings.TherapySettingsButton"]/*[[".cells",".buttons[\"Therapieeinstellungen\"]",".buttons[\"MainView.Settings.TherapySettingsButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        snapshot("41TherapySettings1")
        
        collectionViewsQuery.children(matching: .cell).element(boundBy: 3).children(matching: .other).element(boundBy: 1).children(matching: .other).element.swipeUp()
        
        snapshot("42TherapySettings2")
        
        collectionViewsQuery.children(matching: .cell).element(boundBy: 3).children(matching: .other).element(boundBy: 1).children(matching: .other).element.swipeUp()
        
        snapshot("43TherapySettings3")
        
        app.navigationBars.buttons.element(boundBy: 0).tap() // The back button
        collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["MainView.Settings.AppSettingsButton"]/*[[".cells",".buttons[\"App-Einstellungen\"]",".buttons[\"MainView.Settings.AppSettingsButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        snapshot("44AppSettings")
        
        collectionViewsQuery.switches["MainView.Settings.AppSettingsEditor.OpenFoodFactsWorldwideSearchToggle"].switches.firstMatch.tap()
        collectionViewsQuery.staticTexts["MainView.Settings.AppSettingsEditor.CountryCodeValue"].tap()
        
        snapshot("45FoodDatabaseCountryPicker")
        
        app.navigationBars.buttons.element(boundBy: 0).tap() // The back button
        collectionViewsQuery.switches["MainView.Settings.AppSettingsEditor.OpenFoodFactsWorldwideSearchToggle"].switches.firstMatch.tap()
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
