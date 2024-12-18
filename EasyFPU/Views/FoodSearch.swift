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
            NavigationStack {
                List {
                    ForEach(searchResults) { searchResult in
                        FoodSearchResultPreview(product: searchResult, foodDatabaseResults: foodDatabaseResults, draftFoodItem: self.draftFoodItem, category: self.category, parentPresentation: _presentation)
                            .accessibilityIdentifierBranch(String(searchResult.name.prefix(10)))
                    }
                }
                .navigationBarTitle("Food Database Search")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            // Just close
                            presentation.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle")
                                .imageScale(.large)
                        }
                        .accessibilityIdentifierLeaf("CancelButton")
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            if foodDatabaseResults.selectedEntry != nil {
                                foodDatabaseResults.selectedEntry!.category = category
                                draftFoodItem.fill(with: foodDatabaseResults.selectedEntry!)
                            }
                            // Close sheet
                            presentation.wrappedValue.dismiss()
                        }) {
                            Text("Select").disabled(foodDatabaseResults.selectedEntry == nil)
                        }
                        .accessibilityIdentifierLeaf("SelectButton")
                    }
                }
            }
            .onDisappear() {
                foodDatabaseResults.searchResults = nil
            }
        } else {
            NotificationView {
                ActivityIndicatorSpinner()
            }
        }
    }
}
