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
    @ObservedObject var draftFoodItem: FoodItemViewModel
    @Binding var navigationPath: NavigationPath
    var backNavigationIfSelected: Int = 1
    
    var body: some View {
        FoodPreviewContent(selectedEntry: product)
            .navigationTitle("Scanned Food")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Select") {
                    draftFoodItem.fill(with: product)
                        
                    // Close sheet
                    navigationPath.removeLast(backNavigationIfSelected)
                }
                .accessibilityIdentifierLeaf("SelectButton")
            }
        }
    }
}
