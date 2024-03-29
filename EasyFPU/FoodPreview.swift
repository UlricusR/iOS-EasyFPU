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
            NavigationView {
                FoodPreviewContent(selectedEntry: product)
                .navigationBarTitle("Scanned Food")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            // Just close sheet
                            foodSelected = false
                            presentation.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            databaseResults.selectedEntry = product
                            databaseResults.selectedEntry?.category = category
                            draftFoodItem.fill(with: product)
                                
                            // Close sheet
                            foodSelected = true
                            presentation.wrappedValue.dismiss()
                        }) {
                            Text("Select")
                        }
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
            .navigationViewStyle(StackNavigationViewStyle())
        } else {
            NotificationView {
                ActivityIndicatorSpinner()
            }
        }
    }
}
