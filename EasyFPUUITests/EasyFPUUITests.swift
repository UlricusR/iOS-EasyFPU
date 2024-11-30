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
        collectionViewsQuery/*@START_MENU_TOKEN@*/.images["MainView.CalculateMeal.AddProductToMeal.Chips.SelectFoodItemButton"]/*[[".cells.images[\"MainView.CalculateMeal.AddProductToMeal.Chips.SelectFoodItemButton\"]",".images[\"MainView.CalculateMeal.AddProductToMeal.Chips.SelectFoodItemButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["MainView.CalculateMeal.AddProductToMeal.Chips.SelectFoodItems.TAmount30.TypicalAmountComment"]/*[[".cells",".staticTexts[\"1 Portion\"]",".staticTexts[\"MainView.CalculateMeal.AddProductToMeal.Chips.SelectFoodItems.TAmount30.TypicalAmountComment\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["MainView.CalculateMeal.AddProductToMeal.Chips.SelectFoodItems.AddButton"]/*[[".buttons[\"Hinzufügen\"]",".buttons[\"MainView.CalculateMeal.AddProductToMeal.Chips.SelectFoodItems.AddButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        app/*@START_MENU_TOKEN@*/.buttons["MainView.CalculateMeal.AddProductToMeal.SaveButton"]/*[[".otherElements[\"Ausgewählt\"]",".buttons[\"Ausgewählt\"]",".buttons[\"MainView.CalculateMeal.AddProductToMeal.SaveButton\"]",".otherElements[\"MainView.CalculateMeal.AddProductToMeal.SaveButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        snapshot("04CalculateMealOverview")
        
        collectionViewsQuery.children(matching: .cell).element(boundBy: 3).children(matching: .other).element(boundBy: 1).children(matching: .other).element.swipeUp()
        app.buttons["MainView.CalculateMeal.MealDetailsButton"].tap()
        snapshot("05CalculateMealDetails")
        app.buttons["MainView.CalculateMeal.MealDetails.CloseButton"].tap()
        
        app/*@START_MENU_TOKEN@*/.buttons["MainView.CalculateMeal.ExportButton"]/*[[".otherElements[\"Teilen\"]",".buttons[\"Teilen\"]",".buttons[\"MainView.CalculateMeal.ExportButton\"]",".otherElements[\"MainView.CalculateMeal.ExportButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let mainviewCalculatemealExportmealtohealthMealdelaystepperIncrementButton = app.steppers["MainView.CalculateMeal.ExportMealToHealth.MealDelayStepper"].buttons["MainView.CalculateMeal.ExportMealToHealth.MealDelayStepper-Increment"]
        mainviewCalculatemealExportmealtohealthMealdelaystepperIncrementButton.tap()
        mainviewCalculatemealExportmealtohealthMealdelaystepperIncrementButton.tap()
        snapshot("06AppleHealthExportOverview")
        
        app/*@START_MENU_TOKEN@*/.buttons["MainView.CalculateMeal.ExportMealToHealth.CloseButton"]/*[[".otherElements[\"Schließen\"]",".buttons[\"Schließen\"]",".buttons[\"MainView.CalculateMeal.ExportMealToHealth.CloseButton\"]",".otherElements[\"MainView.CalculateMeal.ExportMealToHealth.CloseButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["MainView.CalculateMeal.ClearButton"]/*[[".otherElements[\"Schließen\"]",".buttons[\"Schließen\"]",".buttons[\"MainView.CalculateMeal.ClearButton\"]",".otherElements[\"MainView.CalculateMeal.ClearButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
                
    }
    
    @MainActor
    func testCookAndBake() throws {
        app/*@START_MENU_TOKEN@*/.buttons["frying.pan"]/*[[".buttons[\"Kochen & Backen\"]",".buttons[\"frying.pan\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        snapshot("10RecipeList")
        
        app/*@START_MENU_TOKEN@*/.buttons["MainView.CookAndBake.AddRecipeButton"]/*[[".otherElements[\"Hinzufügen\"]",".buttons[\"Hinzufügen\"]",".buttons[\"MainView.CookAndBake.AddRecipeButton\"]",".otherElements[\"MainView.CookAndBake.AddRecipeButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        snapshot("11AddIngredients")
        
        app.buttons["MainView.CookAndBake.EditRecipe.AddIngredientsButton"].tap()
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery/*@START_MENU_TOKEN@*/.images["MainView.CookAndBake.EditRecipe.SelectIngredients.Butter.SelectFoodItemButton"]/*[[".cells.images[\"MainView.CookAndBake.EditRecipe.SelectIngredients.Butter.SelectFoodItemButton\"]",".images[\"MainView.CookAndBake.EditRecipe.SelectIngredients.Butter.SelectFoodItemButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["MainView.CookAndBake.EditRecipe.SelectIngredients.Butter.SelectFoodItems.TAmount125.TypicalAmountComment"]/*[[".cells",".staticTexts[\"1 viertel Pfund\"]",".staticTexts[\"MainView.CookAndBake.EditRecipe.SelectIngredients.Butter.SelectFoodItems.TAmount125.TypicalAmountComment\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["MainView.CookAndBake.EditRecipe.SelectIngredients.Butter.SelectFoodItems.AddButton"]/*[[".buttons[\"Hinzufügen\"]",".buttons[\"MainView.CookAndBake.EditRecipe.SelectIngredients.Butter.SelectFoodItems.AddButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.images["MainView.CookAndBake.EditRecipe.SelectIngredients.Eier (GutB.SelectFoodItemButton"]/*[[".cells.images[\"MainView.CookAndBake.EditRecipe.SelectIngredients.Eier (GutB.SelectFoodItemButton\"]",".images[\"MainView.CookAndBake.EditRecipe.SelectIngredients.Eier (GutB.SelectFoodItemButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["MainView.CookAndBake.EditRecipe.SelectIngredients.Eier (GutB.SelectFoodItems.TAmount110.TypicalAmountComment"]/*[[".cells",".staticTexts[\"2 mittelgroße Eier\"]",".staticTexts[\"MainView.CookAndBake.EditRecipe.SelectIngredients.Eier (GutB.SelectFoodItems.TAmount110.TypicalAmountComment\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        snapshot("12SelectIngredient")
        
        app/*@START_MENU_TOKEN@*/.buttons["MainView.CookAndBake.EditRecipe.SelectIngredients.Eier (GutB.SelectFoodItems.AddButton"]/*[[".buttons[\"Hinzufügen\"]",".buttons[\"MainView.CookAndBake.EditRecipe.SelectIngredients.Eier (GutB.SelectFoodItems.AddButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["MainView.CookAndBake.EditRecipe.SelectIngredients.Kakaopulve.FoodItemNameLabel"]/*[[".cells",".staticTexts[\"Kakaopulver (Backfee)\"]",".staticTexts[\"MainView.CookAndBake.EditRecipe.SelectIngredients.Kakaopulve.FoodItemNameLabel\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["MainView.CookAndBake.EditRecipe.SelectIngredients.Kakaopulve.SelectFoodItems.Add50Button"]/*[[".cells",".buttons[\"+50\"]",".buttons[\"MainView.CookAndBake.EditRecipe.SelectIngredients.Kakaopulve.SelectFoodItems.Add50Button\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        app/*@START_MENU_TOKEN@*/.buttons["MainView.CookAndBake.EditRecipe.SelectIngredients.Kakaopulve.SelectFoodItems.AddButton"]/*[[".buttons[\"Hinzufügen\"]",".buttons[\"MainView.CookAndBake.EditRecipe.SelectIngredients.Kakaopulve.SelectFoodItems.AddButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        snapshot("13IngredientsSelected")
        
        app/*@START_MENU_TOKEN@*/.buttons["MainView.CookAndBake.EditRecipe.SelectIngredients.SaveButton"]/*[[".otherElements[\"Ausgewählt\"]",".buttons[\"Ausgewählt\"]",".buttons[\"MainView.CookAndBake.EditRecipe.SelectIngredients.SaveButton\"]",".otherElements[\"MainView.CookAndBake.EditRecipe.SelectIngredients.SaveButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        let mainviewCookandbakeEditrecipeNumberofportionsstepperIncrementButton = collectionViewsQuery/*@START_MENU_TOKEN@*/.steppers["MainView.CookAndBake.EditRecipe.NumberOfPortionsStepper"].buttons["MainView.CookAndBake.EditRecipe.NumberOfPortionsStepper-Increment"]/*[[".cells",".steppers[\"Anzahl Portionen\"]",".buttons[\"Anzahl Portionen, Erhöhen\"]",".buttons[\"MainView.CookAndBake.EditRecipe.NumberOfPortionsStepper-Increment\"]",".steppers[\"MainView.CookAndBake.EditRecipe.NumberOfPortionsStepper\"]"],[[[-1,4,2],[-1,1,2],[-1,0,1]],[[-1,4,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/
        mainviewCookandbakeEditrecipeNumberofportionsstepperIncrementButton.tap()
        mainviewCookandbakeEditrecipeNumberofportionsstepperIncrementButton.tap()
        mainviewCookandbakeEditrecipeNumberofportionsstepperIncrementButton.tap()
        mainviewCookandbakeEditrecipeNumberofportionsstepperIncrementButton.tap()
        mainviewCookandbakeEditrecipeNumberofportionsstepperIncrementButton.tap()
        
        snapshot("14RecipeFinished")
        
        app/*@START_MENU_TOKEN@*/.buttons["MainView.CookAndBake.EditRecipe.SaveButton"]/*[[".otherElements[\"Ausgewählt\"]",".buttons[\"Ausgewählt\"]",".buttons[\"MainView.CookAndBake.EditRecipe.SaveButton\"]",".otherElements[\"MainView.CookAndBake.EditRecipe.SaveButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        snapshot("15RecipeInList")
    }
    
    @MainActor
    func testSearchForProduct() throws {
        app.buttons["birthday.cake"].tap()
        
        snapshot("20DishesList")
        
        app/*@START_MENU_TOKEN@*/.buttons["MainView.MaintainProducts.AddFoodItemButton"]/*[[".otherElements[\"Hinzufügen\"]",".buttons[\"Hinzufügen\"]",".buttons[\"MainView.MaintainProducts.AddFoodItemButton\"]",".otherElements[\"MainView.MaintainProducts.AddFoodItemButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        snapshot("21AddFoodItemEmpty")
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery/*@START_MENU_TOKEN@*/.textFields["MainView.MaintainProducts.EditFoodItem.NameValue"]/*[[".cells",".textFields[\"Name\"]",".textFields[\"MainView.MaintainProducts.EditFoodItem.NameValue\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery.textFields["MainView.MaintainProducts.EditFoodItem.NameValue"].typeText("Chicken McNuggets")
        
        snapshot("22AddFoodItemWithName")
        
        collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["MainView.MaintainProducts.EditFoodItem.SearchButton"]/*[[".cells",".buttons[\"Suchen\"]",".buttons[\"MainView.MaintainProducts.EditFoodItem.SearchButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        sleep(10)
        
        snapshot("23SearchResults")
        
        collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["MainView.MaintainProducts.EditFoodItem.SearchFood.6 Chicken .ProductDetailsButton"]/*[[".cells.buttons[\"MainView.MaintainProducts.EditFoodItem.SearchFood.6 Chicken .ProductDetailsButton\"]",".buttons[\"MainView.MaintainProducts.EditFoodItem.SearchFood.6 Chicken .ProductDetailsButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        snapshot("24SearchResultDetails")
        
        app/*@START_MENU_TOKEN@*/.buttons["MainView.MaintainProducts.EditFoodItem.SearchFood.6 Chicken .ProductDetails.SelectButton"]/*[[".otherElements[\"Übernehmen\"]",".buttons[\"Übernehmen\"]",".buttons[\"MainView.MaintainProducts.EditFoodItem.SearchFood.6 Chicken .ProductDetails.SelectButton\"]",".otherElements[\"MainView.MaintainProducts.EditFoodItem.SearchFood.6 Chicken .ProductDetails.SelectButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        snapshot("25AddFoodItemFilled")
        
        app/*@START_MENU_TOKEN@*/.buttons["MainView.MaintainProducts.EditFoodItem.SaveButton"]/*[[".otherElements[\"Ausgewählt\"]",".buttons[\"Ausgewählt\"]",".buttons[\"MainView.MaintainProducts.EditFoodItem.SaveButton\"]",".otherElements[\"MainView.MaintainProducts.EditFoodItem.SaveButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
    }
    
    @MainActor
    func testEditIngredients() throws {
        app/*@START_MENU_TOKEN@*/.buttons["frying.pan"]/*[[".buttons[\"Kochen & Backen\"]",".buttons[\"frying.pan\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeLeft()
        app.buttons["carrot"].tap()
        
        snapshot("30IngredientsList")
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["MainView.MaintainIngredients.Backhefe (.CarbsUnit"]/*[[".cells.staticTexts[\"MainView.MaintainIngredients.Backhefe (.CarbsUnit\"]",".staticTexts[\"MainView.MaintainIngredients.Backhefe (.CarbsUnit\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeLeft()
        
        snapshot("31FoodListSwipeLeft")
        
        collectionViewsQuery.buttons["MainView.MaintainIngredients.Backhefe (.EditButton"].tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.textFields["MainView.MaintainIngredients.Backhefe (.EditFoodItem.EditTypicalAmountValue"]/*[[".cells",".textFields[\"Menge\"]",".textFields[\"MainView.MaintainIngredients.Backhefe (.EditFoodItem.EditTypicalAmountValue\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.textFields["MainView.MaintainIngredients.Backhefe (.EditFoodItem.EditTypicalAmountValue"]/*[[".cells",".textFields[\"Menge\"]",".textFields[\"MainView.MaintainIngredients.Backhefe (.EditFoodItem.EditTypicalAmountValue\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.typeText("42")
        
        let mainviewMaintainingredientsBackhefeEditfooditemEdittypicalamountcommentTextField = collectionViewsQuery/*@START_MENU_TOKEN@*/.textFields["MainView.MaintainIngredients.Backhefe (.EditFoodItem.EditTypicalAmountComment"]/*[[".cells",".textFields[\"Kommentar\"]",".textFields[\"MainView.MaintainIngredients.Backhefe (.EditFoodItem.EditTypicalAmountComment\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/
        mainviewMaintainingredientsBackhefeEditfooditemEdittypicalamountcommentTextField.tap()
        mainviewMaintainingredientsBackhefeEditfooditemEdittypicalamountcommentTextField.typeText("1 Würfel")
        
        snapshot("32TypicalAmountEntered")
        
        collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["MainView.MaintainIngredients.Backhefe (.EditFoodItem.AddTypicalAmountButton"]/*[[".cells",".buttons[\"Hinzufügen\"]",".buttons[\"MainView.MaintainIngredients.Backhefe (.EditFoodItem.AddTypicalAmountButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        snapshot("33TypicalAmountAdded")
        
        app/*@START_MENU_TOKEN@*/.buttons["MainView.MaintainIngredients.Backhefe (.EditFoodItem.SaveButton"]/*[[".otherElements[\"Ausgewählt\"]",".buttons[\"Ausgewählt\"]",".buttons[\"MainView.MaintainIngredients.Backhefe (.EditFoodItem.SaveButton\"]",".otherElements[\"MainView.MaintainIngredients.Backhefe (.EditFoodItem.SaveButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
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
        
        app/*@START_MENU_TOKEN@*/.buttons["MainView.Settings.TherapySettingsEditor.CancelButton"]/*[[".otherElements[\"Schließen\"]",".buttons[\"Schließen\"]",".buttons[\"MainView.Settings.TherapySettingsEditor.CancelButton\"]",".otherElements[\"MainView.Settings.TherapySettingsEditor.CancelButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        collectionViewsQuery/*@START_MENU_TOKEN@*/.buttons["MainView.Settings.AppSettingsButton"]/*[[".cells",".buttons[\"App-Einstellungen\"]",".buttons[\"MainView.Settings.AppSettingsButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        snapshot("44AppSettings")
        
        collectionViewsQuery/*@START_MENU_TOKEN@*/.staticTexts["MainView.Settings.AppSettingsEditor.CountryCodeValue"]/*[[".cells",".staticTexts[\"DE\"]",".staticTexts[\"MainView.Settings.AppSettingsEditor.CountryCodeValue\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        snapshot("45FoodDatabaseCountryPicker")
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
