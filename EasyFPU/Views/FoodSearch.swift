//
//  SearchResultView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 19.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodSearch: View {
    @ObservedObject var draftFoodItem: FoodItemViewModel
    var searchResults: [FoodDatabaseEntry]
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        //if let searchResults = foodDatabaseResults.searchResults {
            List(searchResults) { searchResult in
                NavigationLink(value: FoodItemEditor.FoodItemEditorNavigationDestination.FoodSearchResultDetails(product: searchResult, backNavigationIfSelected: 2)) {
                    FoodSearchResultPreview(
                        product: searchResult,
                        draftFoodItem: self.draftFoodItem,
                        navigationPath: $navigationPath
                    )
                    .accessibilityIdentifierBranch(String(searchResult.name.prefix(10)))
                }
            }
            .navigationTitle("Food Database Search")
        /*} else {
            NotificationView {
                ActivityIndicatorSpinner()
            }
        }*/
    }
}
