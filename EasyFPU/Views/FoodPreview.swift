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
        ZStack {
            FoodPreviewContent(selectedEntry: product)
                .safeAreaPadding(EdgeInsets(top: 0, leading: 0, bottom: ActionButton.safeButtonSpace, trailing: 0)) // Required to avoid the content to be hidden by the select button
                
            // The overlaying select button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        draftFoodItem.fill(with: product)
                            
                        // Close sheet
                        navigationPath.removeLast(backNavigationIfSelected)
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill").imageScale(.large).foregroundStyle(.green)
                            Text("Select")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ActionButton())
                    .accessibilityIdentifierLeaf("SelectButton")
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("Scanned Food")
    }
}
