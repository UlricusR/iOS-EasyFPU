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
    @Environment(\.presentationMode) var presentation
    @State var errorMessage = ""
    @State var showingAlert = false
    
    var body: some View {
        NavigationView {
            List {
                if foodDatabaseResults.searchResults == nil {
                    Text("No search results (yet)")
                } else {
                    ForEach(foodDatabaseResults.searchResults!) { searchResult in
                        FoodSearchResultPreview(product: searchResult, foodDatabaseResults: foodDatabaseResults, draftFoodItem: self.draftFoodItem, parentPresentation: _presentation)
                    }
                }
            }
            .navigationBarTitle("Food Database Search")
            .navigationBarItems(trailing: Button(action: {
                // Close sheet
                presentation.wrappedValue.dismiss()
            }) {
                Text("Done")
            })
        }
        .onDisappear() {
            foodDatabaseResults.searchResults = nil
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
