//
//  FoodPreview.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 21.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodPreview: View {
    var selectedEntry: FoodDatabaseEntry
    @ObservedObject var draftFoodItem: FoodItemViewModel
    @Environment(\.presentationMode) var presentation
    @State var errorMessage = ""
    @State var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                // The food name
                Text(selectedEntry.name).font(.headline).padding()
                
                HStack {
                    Text("Calories per 100g")
                    Spacer()
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: selectedEntry.caloriesPer100g))!)
                    Text("kcal")
                }
                HStack {
                    Text("Carbs per 100g")
                    Spacer()
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: selectedEntry.carbsPer100g))!)
                    Text("g")
                }
                HStack {
                    Text("Thereof Sugars per 100g")
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: selectedEntry.sugarsPer100g))!)
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
            .navigationBarTitle("Scanned Food")
            .navigationBarItems(leading: Button(action: {
                // Just close sheet
                presentation.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            }, trailing: Button(action: {
                draftFoodItem.fill(with: selectedEntry)
                    
                // Close sheet
                presentation.wrappedValue.dismiss()
                
            }) {
                Text("Select")
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
