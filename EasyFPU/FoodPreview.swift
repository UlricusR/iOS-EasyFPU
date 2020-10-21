//
//  FoodPreview.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 21.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import URLImage

struct FoodPreview: View {
    
    @ObservedObject var foodDatabase: OpenFoodFacts
    @ObservedObject var draftFoodItem: FoodItemViewModel
    private var selectedFoodItem: FoodItemViewModel? {
        if foodDatabase.foodDatabaseEntry == nil {
            return nil
        } else {
            let selectedFoodItem = draftFoodItem
            try? selectedFoodItem.fill(with: foodDatabase.foodDatabaseEntry!)
            return selectedFoodItem
        }
    }
    @Environment(\.presentationMode) var presentation
    @State var errorMessage = ""
    @State var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                if selectedFoodItem == nil {
                    Text("Loading food item...")
                } else {
                    // The food name
                    Text(selectedFoodItem!.name).font(.headline).padding()
                    
                    HStack {
                        Text("Calories per 100g")
                        Spacer()
                        Text(selectedFoodItem!.caloriesPer100gAsString)
                        Text("kcal")
                    }
                    HStack {
                        Text("Carbs per 100g")
                        Spacer()
                        Text(selectedFoodItem!.carbsPer100gAsString)
                        Text("g")
                    }
                    HStack {
                        Text("Thereof Sugars per 100g")
                        Text(selectedFoodItem!.sugarsPer100gAsString)
                        Text("g")
                    }
                    
                    /*if foodDatabase.foodDatabaseEntry!.imageThumbUrl != nil {
                        URLImage(
                            url: URL(foodDatabase.foodDatabaseEntry!.imageThumbUrl!),
                            content: { image in
                                image
                                    .resizable()
                                    .aspectRation(contentMode: .fit)
                            }
                        )
                    }*/
                    
                    Spacer()
                }
            }
            .navigationBarTitle("Scanned Food")
            .navigationBarItems(leading: Button(action: {
                // Just close sheet
                presentation.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            }, trailing: Button(action: {
                if let selectedResult = foodDatabase.foodDatabaseEntry {
                    do {
                        try draftFoodItem.fill(with: selectedResult)
                        
                        // Close sheet
                        presentation.wrappedValue.dismiss()
                    } catch FoodDatabaseError.incompleteData(let errorMessage) {
                        self.errorMessage = errorMessage
                        showingAlert = true
                    } catch FoodDatabaseError.typeError(let errorMessage) {
                        self.errorMessage = errorMessage
                        showingAlert = true
                    } catch {
                        self.errorMessage = error.localizedDescription
                        showingAlert = true
                    }
                }
                
            }) {
                Text("Select").disabled(foodDatabase.foodDatabaseEntry == nil)
            })
        }
        .alert(isPresented: self.$showingAlert) {
            Alert(
                title: Text("Data alert"),
                message: Text(self.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
