//
//  FoodSearchResultPreview.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 19.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import URLImage

struct FoodSearchResultPreview: View {
    var product: FoodDatabaseEntry
    @ObservedObject var editedCDFoodItem: FoodItem
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        HStack {
            if let imageObject = product.imageFront {
                URLImage(imageObject.thumb) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                }
                .accessibilityIdentifierLeaf("ProductImage")
            }
            
            Text(product.name)
                .font(.headline)
                .accessibilityIdentifierLeaf("ProductName")
        }
        .swipeActions(allowsFullSwipe: true) {
            // Selecting the product
            Button("Select", systemImage: "checkmark.circle") {
                FoodItem.fill(foodItem: editedCDFoodItem, with: product)
                navigationPath.removeLast()
            }
            .tint(.green)
            .accessibilityIdentifierLeaf("SelectButton")
        }
    }
}
