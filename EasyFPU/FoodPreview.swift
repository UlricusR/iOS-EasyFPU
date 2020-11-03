//
//  FoodPreview.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 21.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodPreview: View {
    var product: FoodDatabaseEntry
    @ObservedObject var databaseResults: FoodDatabaseResults
    @ObservedObject var draftFoodItem: FoodItemViewModel
    var category: FoodItemCategory
    @Binding var productWasChosen: Bool
    @Environment(\.presentationMode) var presentation
    @State private var errorMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            FoodPreviewContent(selectedEntry: product)
            .navigationBarTitle("Scanned Food")
            .navigationBarItems(leading: Button(action: {
                // Just close sheet
                productWasChosen = false
                presentation.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            }, trailing: Button(action: {
                databaseResults.selectedEntry = product
                databaseResults.selectedEntry?.category = category
                draftFoodItem.fill(with: product)
                
                // Set product to chosen
                productWasChosen = true
                    
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
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
