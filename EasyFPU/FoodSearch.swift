//
//  SearchResultView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 19.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodSearch: View {
    @ObservedObject var foodDatabaseResults: FoodDatabaseResults
    @ObservedObject var draftFoodItem: FoodItemViewModel
    var category: FoodItemCategory
    @Environment(\.presentationMode) var presentation
    @State var errorMessage = ""
    @State var showingAlert = false
    
    var body: some View {
        if let searchResults = foodDatabaseResults.searchResults {
            NavigationView {
                List {
                    ForEach(searchResults) { searchResult in
                        FoodSearchResultPreview(product: searchResult, foodDatabaseResults: foodDatabaseResults, draftFoodItem: self.draftFoodItem, category: self.category, parentPresentation: _presentation)
                    }
                }
                .navigationBarTitle("Food Database Search")
                .navigationBarItems(leading: Button(action: {
                    // Just close
                    presentation.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                }, trailing: Button(action: {
                    if foodDatabaseResults.selectedEntry != nil {
                        foodDatabaseResults.selectedEntry!.category = category
                        draftFoodItem.fill(with: foodDatabaseResults.selectedEntry!)
                    }
                    // Close sheet
                    presentation.wrappedValue.dismiss()
                }) {
                    Text("Select").disabled(foodDatabaseResults.selectedEntry == nil)
                })
            }
            .onDisappear() {
                foodDatabaseResults.searchResults = nil
            }
            .navigationViewStyle(StackNavigationViewStyle())
        } else {
            NotificationView {
                ActivityIndicatorSpinner()
            }
        }
    }
}
