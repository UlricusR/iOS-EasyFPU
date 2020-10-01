//
//  ContentView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 11.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodList: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: FoodItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \FoodItem.name, ascending: true)
        ]
    ) var foodItems: FetchedResults<FoodItem>
    @FetchRequest(
        entity: AbsorptionBlock.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \AbsorptionBlock.absorptionTime, ascending: true)
        ]
    ) var absorptionBlocks: FetchedResults<AbsorptionBlock>
    @ObservedObject var absorptionScheme = AbsorptionScheme()
    
    @State private var activeSheet: FoodListSheets.State?
    
    @State var showingMenu = false
    @State var showingAlert = false
    @State var showActionSheet = false
    @State var errorMessage = ""
    @State var draftFoodItem = FoodItemViewModel(
        name: "",
        favorite: false,
        caloriesPer100g: 0.0,
        carbsPer100g: 0.0,
        sugarsPer100g: 0.0,
        amount: 0
    )
    @State var foodItemsToBeImported: [FoodItemViewModel]?
    @State private var searchString = ""
    @State private var showCancelButton: Bool = false
    @State private var showFavoritesOnly = false
    @State private var disclaimerViewIsDisplayed = !(UserSettings.getValue(for: UserSettings.UserDefaultsBoolKey.disclaimerAccepted) ?? false)
    private let helpScreen = HelpScreen.foodList

    var filteredFoodItems: [FoodItemViewModel] {
        if searchString == "" {
            return showFavoritesOnly ? foodItems.map { FoodItemViewModel(from: $0) } .filter { $0.favorite } : foodItems.map { FoodItemViewModel(from: $0) }
        } else {
            return showFavoritesOnly ? foodItems.map { FoodItemViewModel(from: $0) } .filter { $0.favorite && $0.name.lowercased().contains(searchString.lowercased()) } : foodItems.map { FoodItemViewModel(from: $0) } .filter { $0.name.lowercased().contains(searchString.lowercased()) }
        }
    }
    
    var meal: MealViewModel {
        let meal = MealViewModel(name: "Total meal")
        for foodItem in foodItems {
            if foodItem.amount > 0 {
                meal.add(foodItem: FoodItemViewModel(from: foodItem))
            }
        }
        return meal
    }
    
    var body: some View {
        let drag = DragGesture()
        .onEnded {
            if $0.translation.width < -100 {
                withAnimation {
                    self.showingMenu = false
                }
            }
        }
        
        if self.disclaimerViewIsDisplayed {
            return AnyView(
                DisclaimerView()
            )
        } else {
            return AnyView(
                ZStack(alignment: .leading) {
                    GeometryReader { geometry in
                        NavigationView {
                            VStack {
                                List {
                                    // Search view
                                    SearchView(searchString: self.$searchString, showCancelButton: self.$showCancelButton)
                                        .padding(.horizontal)
                                    Text("Tap to select, long press to edit").font(.caption)
                                    ForEach(self.filteredFoodItems, id: \.self) { foodItem in
                                        FoodItemView(absorptionScheme: self.absorptionScheme, foodItem: foodItem)
                                            .environment(\.managedObjectContext, self.managedObjectContext)
                                    }
                                    .onDelete(perform: self.deleteFoodItem)
                                }
                                
                                if self.meal.amount > 0 {
                                    MealSummaryView(activeFoodListSheet: self.$activeSheet, absorptionScheme: self.absorptionScheme, meal: self.meal)
                                }
                            }
                            .navigationBarTitle("Food List")
                            .navigationBarItems(
                                leading: HStack {
                                    Button(action: {
                                        withAnimation {
                                            self.showingMenu.toggle()
                                        }
                                    }) {
                                        Image(systemName: "line.horizontal.3")
                                        .imageScale(.large)
                                    }
                                    
                                    Button(action: {
                                        withAnimation {
                                            self.activeSheet = .help
                                        }
                                    }) {
                                        Image(systemName: "questionmark.circle")
                                        .imageScale(.large)
                                        .padding()
                                    }
                                },
                                trailing: HStack {
                                    Button(action: {
                                        withAnimation {
                                            self.showFavoritesOnly.toggle()
                                        }
                                    }) {
                                        if self.showFavoritesOnly {
                                            Image(systemName: "star.fill")
                                            .foregroundColor(Color.yellow)
                                            .padding()
                                        } else {
                                            Image(systemName: "star")
                                            .foregroundColor(Color.gray)
                                            .padding()
                                        }
                                    }
                                    
                                    Button(action: {
                                        // Add new food item
                                        self.draftFoodItem = FoodItemViewModel(
                                            name: "",
                                            favorite: false,
                                            caloriesPer100g: 0.0,
                                            carbsPer100g: 0.0,
                                            sugarsPer100g: 0.0,
                                            amount: 0
                                        )
                                        activeSheet = .addFoodItem
                                    }) {
                                        Image(systemName: "plus.circle")
                                            .imageScale(.large)
                                            .foregroundColor(.green)
                                    }
                                }
                            )
                        }
                        .navigationViewStyle(StackNavigationViewStyle())
                        .sheet(item: $activeSheet) {
                            sheetContent($0)
                        }
                        .onAppear {
                            if self.absorptionScheme.absorptionBlocks.isEmpty {
                                // Absorption scheme hasn't been loaded yet
                                if self.absorptionBlocks.isEmpty {
                                    // Absorption blocks are empty, so initialize with default absorption scheme
                                    // and store default blocks back to core data
                                    guard let defaultAbsorptionBlocks = DataHelper.loadDefaultAbsorptionBlocks(errorMessage: &self.errorMessage) else {
                                        self.showingAlert = true
                                        return
                                    }
                                    
                                    for absorptionBlock in defaultAbsorptionBlocks {
                                        let cdAbsorptionBlock = AbsorptionBlock(context: self.managedObjectContext)
                                        cdAbsorptionBlock.absorptionTime = Int64(absorptionBlock.absorptionTime)
                                        cdAbsorptionBlock.maxFpu = Int64(absorptionBlock.maxFpu)
                                        if !self.absorptionScheme.absorptionBlocks.contains(cdAbsorptionBlock) {
                                            self.absorptionScheme.addToAbsorptionBlocks(newAbsorptionBlock: cdAbsorptionBlock)
                                        }
                                    }
                                    try? AppDelegate.viewContext.save()
                                } else {
                                    // Store absorption blocks loaded from core data
                                    self.absorptionScheme.absorptionBlocks = self.absorptionBlocks.sorted()
                                }
                                
                                // Publish change
                                self.absorptionScheme.objectWillChange.send()
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(x: self.showingMenu ? geometry.size.width/2 : 0)
                        .disabled(self.showingMenu ? true : false)
                        
                        if self.showingMenu {
                            MenuView(draftAbsorptionScheme: AbsorptionSchemeViewModel(from: self.absorptionScheme), absorptionScheme: self.absorptionScheme, filePicked: self.importJSON, exportDirectory: self.exportJSON)
                                .frame(width: geometry.size.width/2)
                                .transition(.move(edge: .leading))
                        }
                    }
                }
                .gesture(drag)
                .alert(isPresented: self.$showingAlert) {
                    Alert(
                        title: Text("Notice"),
                        message: Text(self.errorMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .actionSheet(isPresented: self.$showActionSheet) {
                    ActionSheet(title: Text("Import food list"), message: Text("Please select"), buttons: [
                        .default(Text("Replace")) {
                            FoodItem.deleteAll()
                            self.importFoodItems()
                        },
                        .default(Text("Append")) {
                            self.importFoodItems()
                        },
                        .cancel()
                    ])
                }
            )
        }
    }
    
    private func deleteFoodItem(at offsets: IndexSet) {
        offsets.forEach { index in
            guard let foodItem = self.filteredFoodItems[index].cdFoodItem else {
                errorMessage = NSLocalizedString("Cannot delete food item", comment: "")
                showingAlert = true
                return
            }
            
            // Delete typical amounts first
            let typicalAmountsToBeDeleted = foodItem.typicalAmounts
            if typicalAmountsToBeDeleted != nil {
                for typicalAmountToBeDeleted in typicalAmountsToBeDeleted! {
                    self.managedObjectContext.delete(typicalAmountToBeDeleted as! TypicalAmount)
                }
                foodItem.removeFromTypicalAmounts(typicalAmountsToBeDeleted!)
            }
            
            // Delete food item
            self.managedObjectContext.delete(foodItem)
        }
        
        try? AppDelegate.viewContext.save()
    }
    
    private func importJSON(_ url: URL) {
        debugPrint("Trying to import following file: \(url)")
        
        // Make sure we can access file
        guard url.startAccessingSecurityScopedResource() else {
            debugPrint("Failed to access \(url)")
            errorMessage = "Failed to access \(url)"
            showingAlert = true
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        // Read data
        var jsonData: Data
        do {
            jsonData = try Data(contentsOf: url)
        } catch {
            debugPrint(error.localizedDescription)
            errorMessage = error.localizedDescription
            showingAlert = true
            return
        }
        
        // Decode JSON
        let decoder = JSONDecoder()
        
        do {
            self.foodItemsToBeImported = try decoder.decode([FoodItemViewModel].self, from: jsonData)
            self.showActionSheet = true
        } catch DecodingError.keyNotFound(let key, let context) {
            errorMessage = NSLocalizedString("Failed to decode due to missing key ", comment: "") + key.stringValue + " - " + context.debugDescription
            showingAlert = true
        } catch DecodingError.typeMismatch(_, let context) {
            errorMessage = NSLocalizedString("Failed to decode due to type mismatch - ", comment: "") + context.debugDescription
            showingAlert = true
        } catch DecodingError.valueNotFound(let type, let context) {
            errorMessage = NSLocalizedString("Failed to decode due to missing value - ", comment: "") + "\(type)" + " - " + context.debugDescription
            showingAlert = true
        } catch DecodingError.dataCorrupted(_) {
            errorMessage = NSLocalizedString("Failed to decode because it appears to be invalid JSON", comment: "")
            showingAlert = true
        } catch {
            errorMessage = NSLocalizedString("Failed to decode - ", comment: "") + error.localizedDescription
            showingAlert = true
        }
    }
    
    private func exportJSON(_ url: URL) {
        // Make sure we can access file
        guard url.startAccessingSecurityScopedResource() else {
            debugPrint("Failed to access \(url)")
            errorMessage = "Failed to access \(url)"
            showingAlert = true
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        // Write file
        var fileName = ""
        if DataHelper.exportFoodItems(url, fileName: &fileName) {
            errorMessage = NSLocalizedString("Successfully exported food list to: ", comment: "") + fileName
            showingAlert = true
        } else {
            errorMessage = NSLocalizedString("Failed to export food list to: ", comment: "") + fileName
            showingAlert = true
        }
        withAnimation { showingMenu = false }
    }
    
    private func importFoodItems() {
        if foodItemsToBeImported != nil {
            for foodItemToBeImported in foodItemsToBeImported! {
                var newFoodItem = FoodItem(context: managedObjectContext)
                foodItemToBeImported.updateCDFoodItem(&newFoodItem)
                for typicalAmount in foodItemToBeImported.typicalAmounts {
                    let newCDTypicalAmount = TypicalAmount(context: managedObjectContext)
                    newCDTypicalAmount.amount = Int64(typicalAmount.amount)
                    newCDTypicalAmount.comment = typicalAmount.comment
                    newFoodItem.addToTypicalAmounts(newCDTypicalAmount)
                }
            }
            try? AppDelegate.viewContext.save()
        } else {
            errorMessage = "Could not import food list"
            showingAlert = true
        }
        withAnimation {
            self.showingMenu = false
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: FoodListSheets.State) -> some View {
        switch state {
        case .addFoodItem:
            FoodItemEditor(
                navigationBarTitle: NSLocalizedString("New food item", comment: ""),
                draftFoodItem: draftFoodItem
            ).environment(\.managedObjectContext, managedObjectContext)
        case .mealDetails:
            MealDetail(absorptionScheme: self.absorptionScheme, meal: self.meal)
        case .help:
            HelpView(helpScreen: helpScreen)
        }
    }
}
