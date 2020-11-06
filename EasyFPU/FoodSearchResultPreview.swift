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
    @ObservedObject var foodDatabaseResults: FoodDatabaseResults
    @ObservedObject var draftFoodItem: FoodItemViewModel
    var category: FoodItemCategory
    @State private var selectedEntry: FoodDatabaseEntry?
    @State private var foodSelected = false
    @State private var showDetails: Bool = false
    @Environment(\.presentationMode) var parentPresentation
    
    var body: some View {
        HStack {
            Button(action: {
                self.foodDatabaseResults.selectedEntry = product
            }) {
                Image(systemName: self.foodDatabaseResults.selectedEntry == product ? "checkmark.circle.fill" : "circle").foregroundColor(.green)
            }.buttonStyle(BorderlessButtonStyle())
            
            if let imageObject = product.imageFront {
                URLImage(url: imageObject.thumb) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                }
            }
            
            Text(product.name).font(.headline)
                .onTapGesture {
                    self.foodDatabaseResults.selectedEntry = product
                }
            
            Button(action: {
                withAnimation {
                    self.showDetails.toggle()
                }
            }) {
                Image(systemName: "info.circle")
                    .imageScale(.large)
            }.buttonStyle(BorderlessButtonStyle())
        }
        .sheet(isPresented: $showDetails) {
            FoodPreview(product: $selectedEntry, databaseResults: foodDatabaseResults, draftFoodItem: draftFoodItem, category: category, foodSelected: $foodSelected)
            .onDisappear() {
                if foodSelected {
                    parentPresentation.wrappedValue.dismiss()
                }
            }
        }
        .onAppear() {
            self.selectedEntry = self.product
        }
    }
}
