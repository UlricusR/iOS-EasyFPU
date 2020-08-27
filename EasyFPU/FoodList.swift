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
    var absorptionScheme = AbsorptionScheme()
    @State var showingSheet = false
    @State var showingMenu = false
    @State var showingAlert = false
    @State var showActionSheet = false
    @State var activeSheet = ActiveFoodListSheet.addFoodItem
    @State var errorMessage = ""
    @State var draftFoodItem = FoodItemViewModel(
        name: "",
        favorite: false,
        caloriesPer100g: 0.0,
        carbsPer100g: 0.0,
        amount: 0
    )
    @State var foodItemsToBeImported: [FoodItemViewModel]?
    @State private var searchString = ""
    @State private var showCancelButton: Bool = false
    @State private var showFavoritesOnly = false

    var filteredFoodItems: [FoodItemViewModel] {
        if searchString == "" {
            return showFavoritesOnly ? foodItems.map { FoodItemViewModel(from: $0) } .filter { $0.favorite } : foodItems.map { FoodItemViewModel(from: $0) }
        } else {
            return showFavoritesOnly ? foodItems.map { FoodItemViewModel(from: $0) } .filter { $0.favorite && $0.name.contains(searchString) } : foodItems.map { FoodItemViewModel(from: $0) } .filter { $0.name.contains(searchString) }
        }
    }
    
    var meal: Meal {
        var meal = Meal(name: "Total meal")
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
        
        return ZStack(alignment: .leading) {
            GeometryReader { geometry in
                VStack {
                    NavigationView {
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
                        .navigationBarTitle("Food List")
                        .navigationBarItems(
                            leading: Button(action: {
                                withAnimation {
                                    self.showingMenu.toggle()
                                }
                            }) {
                                Image(systemName: "line.horizontal.3")
                                    .imageScale(.large)
                            },
                            trailing: Button(action: {
                                // Add new food item
                                self.draftFoodItem = FoodItemViewModel(
                                    name: "",
                                    favorite: false,
                                    caloriesPer100g: 0.0,
                                    carbsPer100g: 0.0,
                                    amount: 0
                                )
                                self.activeSheet = .addFoodItem
                                self.showingSheet = true
                            }) {
                                Image(systemName: "plus.circle")
                                    .imageScale(.large)
                                    .foregroundColor(.green)
                            }
                        )
                    }
                    
                    if self.meal.amount > 0 {
                        VStack {
                            Text("Total meal").font(.headline)
                            
                            HStack {
                                VStack {
                                    HStack {
                                        Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.carbs))!)
                                        Text("g")
                                    }
                                    Text("Carbs").font(.caption)
                                }
                                
                                VStack {
                                    HStack {
                                        Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.fpus.getExtendedCarbs()))!)
                                        Text("g")
                                    }
                                    Text("Extended Carbs").font(.caption)
                                }
                                
                                VStack {
                                    HStack {
                                        Text(NumberFormatter().string(from: NSNumber(value: self.meal.fpus.getAbsorptionTime(absorptionScheme: self.absorptionScheme)))!)
                                        Text("h")
                                    }
                                    Text("Absorption Time").font(.caption)
                                }
                            }
                        }
                        .onTapGesture {
                            self.activeSheet = .showMealDetails
                            self.showingSheet = true
                        }
                        .foregroundColor(.red)
                    }
                }
                .sheet(isPresented: self.$showingSheet) {
                    FoodListSheets(
                        activeSheet: self.activeSheet,
                        isPresented: self.$showingSheet,
                        draftFoodItem: self.draftFoodItem,
                        absorptionScheme: self.absorptionScheme,
                        meal: self.meal
                    )
                        .environment(\.managedObjectContext, self.managedObjectContext)
                }
                .onAppear {
                    if self.absorptionScheme.absorptionBlocks.isEmpty {
                        // Absorption scheme hasn't been loaded yet
                        if self.absorptionBlocks.isEmpty {
                            // Absorption blocks are empty, so initialize with default absorption scheme
                            // and store default blocks back to core data
                            let defaultAbsorptionBlocks = DataHelper.loadDefaultAbsorptionBlocks()
                            
                            for absorptionBlock in defaultAbsorptionBlocks {
                                let cdAbsorptionBlock = AbsorptionBlock(context: self.managedObjectContext)
                                cdAbsorptionBlock.absorptionTime = Int64(absorptionBlock.absorptionTime)
                                cdAbsorptionBlock.maxFpu = Int64(absorptionBlock.maxFpu)
                                self.absorptionScheme.addToAbsorptionBlocks(newAbsorptionBlock: cdAbsorptionBlock)
                            }
                            try? AppDelegate.viewContext.save()
                        } else {
                            // Store absorption blocks loaded from core data
                            self.absorptionScheme.absorptionBlocks = self.absorptionBlocks.sorted()
                        }
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
    }
    
    private func deleteFoodItem(at offsets: IndexSet) {
        offsets.forEach { index in
            let foodItem = self.filteredFoodItems[index].cdFoodItem!
            
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
        guard let jsonData = try? Data(contentsOf: url) else {
            errorMessage = NSLocalizedString("Unable to open URL: ", comment: "") + url.absoluteString
            showingAlert = true
            return
        }
        
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
}
