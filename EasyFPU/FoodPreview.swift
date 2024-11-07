//
//  FoodPreview.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 21.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodPreview: View {
    @Binding var product: FoodDatabaseEntry?
    @ObservedObject var databaseResults: FoodDatabaseResults
    @ObservedObject var draftFoodItem: FoodItemViewModel
    var category: FoodItemCategory
    @Binding var foodSelected: Bool
    @Environment(\.presentationMode) var presentation
    @State private var errorMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        if let product = product {
            NavigationStack {
                FoodPreviewContent(selectedEntry: product)
                .navigationBarTitle("Scanned Food")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            // Just close sheet
                            foodSelected = false
                            presentation.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle")
                                .imageScale(.large)
                        }
                        .accessibilityIdentifierLeaf("CancelButton")
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Select") {
                            databaseResults.selectedEntry = product
                            databaseResults.selectedEntry?.category = category
                            draftFoodItem.fill(with: product)
                                
                            // Close sheet
                            foodSelected = true
                            presentation.wrappedValue.dismiss()
                        }
                        .accessibilityIdentifierLeaf("SelectButton")
                    }
                }
            }
            .alert(isPresented: self.$showingAlert) {
                Alert(
                    title: Text("Data alert"),
                    message: Text(self.errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        } else {
            NotificationView {
                ActivityIndicatorSpinner()
            }
        }
    }
}
