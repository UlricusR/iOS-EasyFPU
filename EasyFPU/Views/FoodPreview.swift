//
//  FoodPreview.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 21.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodPreview: View {
    enum FoodPreviewNavigationDestination: Hashable {
        case Preview(url: URL)
    }
    
    @State var product: FoodDatabaseEntry
    @ObservedObject var editedCDFoodItem: FoodItem
    @Binding var navigationPath: NavigationPath
    var backNavigationIfSelected: Int = 1
    @State var scale: CGFloat = 1.0
    @State var isTapped: Bool = false
    @State var pointTapped: CGPoint = CGPoint.zero
    @State var draggedSize: CGSize = CGSize.zero
    @State var previousDragged: CGSize = CGSize.zero
    
    var body: some View {
        ZStack {
            List {
                Section(header: Text("Food Details")) {
                    HStack {
                        Text("Name")
                            .accessibilityIdentifierLeaf("NameLabel")
                        Spacer()
                        Text(product.name)
                            .accessibilityIdentifierLeaf("NameValue")
                            .fontWeight(.bold)
                    }
                    
                    if product.quantity > 0 {
                        HStack {
                            Text("Quantity")
                                .accessibilityIdentifierLeaf("QuantityLabel")
                            Spacer()
                            Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: product.quantity))!)
                                .accessibilityIdentifierLeaf("QuantityValue")
                            Text(product.quantityUnit.rawValue)
                                .accessibilityIdentifierLeaf("QuantityUnit")
                        }
                    }
                    
                    HStack {
                        Text("Calories per 100g")
                            .accessibilityIdentifierLeaf("CaloriesLabel")
                        Spacer()
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: product.caloriesPer100g.getEnergyInKcal()))!)
                            .accessibilityIdentifierLeaf("CaloriesValue")
                        Text("kcal")
                            .accessibilityIdentifierLeaf("CaloriesUnit")
                    }
                    
                    HStack {
                        Text("Carbs per 100g")
                            .accessibilityIdentifierLeaf("CarbsLabel")
                        Spacer()
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: product.carbsPer100g))!)
                            .accessibilityIdentifierLeaf("CarbsValue")
                        Text("g")
                            .accessibilityIdentifierLeaf("CarbsUnit")
                    }
                    
                    HStack {
                        Text("Thereof Sugars per 100g")
                            .accessibilityIdentifierLeaf("SugarsLabel")
                        Spacer()
                        Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: product.sugarsPer100g))!)
                            .accessibilityIdentifierLeaf("SugarsValue")
                        Text("g")
                            .accessibilityIdentifierLeaf("SugarsUnit")
                    }
                }
                
                if product.imageFront != nil || product.imageNutriments != nil || product.imageIngredients != nil {
                    Section(header: Text("Images")) {
                        ScrollView(.horizontal) {
                            HStack {
                                getThumbView(image: product.imageFront)
                                getThumbView(image: product.imageNutriments)
                                getThumbView(image: product.imageIngredients)
                            }
                            .accessibilityIdentifierLeaf("FoodImages")
                        }
                    }
                }
                
                HStack {
                    Text(NSLocalizedString("Link to entry in ", comment: "") + UserSettings.shared.foodDatabase.databaseType.rawValue)
                        .foregroundStyle(.blue)
                        .onTapGesture {
                            try? UIApplication.shared.open(UserSettings.shared.foodDatabase.getLink(for: product.sourceId))
                        }
                        .accessibilityIdentifierLeaf("LinkToFoodDatabaseEntry")
                }
            }
            .safeAreaPadding(EdgeInsets(top: 0, leading: 0, bottom: ActionButton.safeButtonSpace, trailing: 0)) // Required to avoid the content to be hidden by the select button
                
            // The overlaying select button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        editedCDFoodItem.fill(with: product)
                            
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
        .navigationDestination(for: FoodPreviewNavigationDestination.self) { screen in
            switch screen {
            case .Preview(let url):
                FoodImage(url: url, name: product.name)
            }
        }
    }
    
    init(
        product: FoodDatabaseEntry,
        editedCDFoodItem: FoodItem,
        navigationPath: Binding<NavigationPath>,
        backNavigationIfSelected: Int = 1
    ) {
        self.product = product
        self.editedCDFoodItem = editedCDFoodItem
        self._navigationPath = navigationPath
        self.backNavigationIfSelected = backNavigationIfSelected
        
        // Check for missing images
        if product.imageFront == nil || product.imageNutriments == nil || product.imageIngredients == nil {
            UserSettings.shared.foodDatabase.prepare(product.sourceId, category: product.category) { result in
                switch result {
                case .success(let networkFoodDatabaseEntry):
                    guard let foodDatabaseEntry = networkFoodDatabaseEntry else {
                        // This should not happen as we already have the entry
                        return
                    }
                    DispatchQueue.main.async {
                        product.imageFront = foodDatabaseEntry.imageFront
                        product.imageNutriments = foodDatabaseEntry.imageNutriments
                        product.imageIngredients = foodDatabaseEntry.imageIngredients
                    }
                    
                case .failure(let error):
                    debugPrint(error.evaluate())
                }
            }
        }
    }
    
    @ViewBuilder
    private func getThumbView(image: FoodDatabaseImage?) -> some View {
        if image != nil {
            AsyncImage(url: image!.thumb) { image in
                image
            } placeholder: {
                Color.gray
            }
            .padding()
            .onTapGesture {
                navigationPath.append(FoodPreviewNavigationDestination.Preview(url: image!.image))
            }
        }
    }
}
