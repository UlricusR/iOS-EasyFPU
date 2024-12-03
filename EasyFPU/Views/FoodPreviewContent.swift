//
//  FoodPreviewContent.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 28.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import URLImage

struct FoodPreviewContent: View {
    enum SheetState: Identifiable {
        case front
        case nutriments
        case ingredients
        
        var id: SheetState { self }
    }
    
    var selectedEntry: FoodDatabaseEntry
    @State var activeSheet: SheetState?
    @State var scale: CGFloat = 1.0
    @State var isTapped: Bool = false
    @State var pointTapped: CGPoint = CGPoint.zero
    @State var draggedSize: CGSize = CGSize.zero
    @State var previousDragged: CGSize = CGSize.zero
    
    var body: some View {
        VStack {
            // The food name
            Text(selectedEntry.name)
                .font(.headline)
                .padding()
                .accessibilityIdentifierLeaf("FoodName")
            
            ScrollView(.horizontal) {
                HStack {
                    getThumbView(image: selectedEntry.imageFront)
                        .padding()
                        .onTapGesture {
                            self.activeSheet = .front
                        }
                    
                    getThumbView(image: selectedEntry.imageNutriments)
                        .padding()
                        .onTapGesture {
                            self.activeSheet = .nutriments
                        }
                    
                    getThumbView(image: selectedEntry.imageIngredients)
                        .padding()
                        .onTapGesture {
                            self.activeSheet = .ingredients
                        }
                }
                .accessibilityIdentifierLeaf("FoodImages")
            }
            
            if selectedEntry.quantity > 0 {
                HStack {
                    Text("Quantity")
                        .accessibilityIdentifierLeaf("QuantityLabel")
                    Spacer()
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: selectedEntry.quantity))!)
                        .accessibilityIdentifierLeaf("QuantityValue")
                    Text(selectedEntry.quantityUnit.rawValue)
                        .accessibilityIdentifierLeaf("QuantityUnit")
                }.padding([.leading, .trailing])
            }
            HStack {
                Text("Calories per 100g")
                    .accessibilityIdentifierLeaf("CaloriesLabel")
                Spacer()
                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: selectedEntry.caloriesPer100g.getEnergyInKcal()))!)
                    .accessibilityIdentifierLeaf("CaloriesValue")
                Text("kcal")
                    .accessibilityIdentifierLeaf("CaloriesUnit")
            }.padding([.leading, .trailing])
            HStack {
                Text("Carbs per 100g")
                    .accessibilityIdentifierLeaf("CarbsLabel")
                Spacer()
                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: selectedEntry.carbsPer100g))!)
                    .accessibilityIdentifierLeaf("CarbsValue")
                Text("g")
                    .accessibilityIdentifierLeaf("CarbsUnit")
            }.padding([.leading, .trailing])
            HStack {
                Text("Thereof Sugars per 100g")
                    .accessibilityIdentifierLeaf("SugarsLabel")
                Spacer()
                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: selectedEntry.sugarsPer100g))!)
                    .accessibilityIdentifierLeaf("SugarsValue")
                Text("g")
                    .accessibilityIdentifierLeaf("SugarsUnit")
            }.padding([.leading, .trailing])
            
            HStack {
                Text(NSLocalizedString("Link to entry in ", comment: "") + UserSettings.shared.foodDatabase.databaseType.rawValue)
                    .padding().foregroundStyle(.blue)
                    .onTapGesture {
                        try? UIApplication.shared.open(UserSettings.shared.foodDatabase.getLink(for: selectedEntry.sourceId))
                    }
                    .accessibilityIdentifierLeaf("LinkToFoodDatabaseEntry")
            }
            
            Spacer()
        }
        .sheet(item: $activeSheet) {
            sheetContent($0)
        }
    }
    
    @ViewBuilder
    private func getThumbView(image: FoodDatabaseImage?) -> some View {
        if image != nil {
            URLImage(image!.thumb) { image in
                image
            }
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: SheetState) -> some View {
        switch state {
        case .front:
            if selectedEntry.imageFront != nil {
                NavigationStack {
                    GeometryReader { reader in
                        getImageView(url: selectedEntry.imageFront!.image, for: reader)
                        .navigationBarTitle(selectedEntry.name)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    self.activeSheet = nil
                                }) {
                                    Text("Done")
                                }
                            }
                        }
                    }
                }
            }
        case .nutriments:
            if selectedEntry.imageNutriments != nil {
                NavigationStack {
                    GeometryReader { reader in
                        getImageView(url: selectedEntry.imageNutriments!.image, for: reader)
                        .navigationBarTitle(selectedEntry.name)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    self.activeSheet = nil
                                }) {
                                    Text("Done")
                                }
                            }
                        }
                    }
                }
            }
        case .ingredients:
            if selectedEntry.imageIngredients != nil {
                NavigationStack {
                    GeometryReader { reader in
                        getImageView(url: selectedEntry.imageIngredients!.image, for: reader)
                        .navigationBarTitle(selectedEntry.name)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    self.activeSheet = nil
                                }) {
                                    Text("Done")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func getImageView(url: URL, for reader: GeometryProxy) -> some View {
        URLImage(url) { image in
            image
                .resizable()
                .scaledToFit()
                .animation(.default, value: self.pointTapped)
                .offset(x: self.draggedSize.width, y: 0)
                .scaleEffect(self.scale)
                .scaleEffect(self.isTapped ? 2 : 1,
                 anchor: UnitPoint(
                  x: self.pointTapped.x / reader.frame(in: .global).maxX,
                  y: self.pointTapped.y / reader.frame(in: .global).maxY
                  ))
                 .gesture(TapGesture(count: 2)
                 .onEnded({
                self.isTapped = !self.isTapped
            })
            .simultaneously(with: DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged({ (value) in
                self.pointTapped = value.startLocation
                self.draggedSize = CGSize(
                     width: value.translation.width + self.previousDragged.width,
                     height: value.translation.height + self.previousDragged.height)

            }).onEnded({ (value) in
                let globalMaxX = reader.frame(in: .global).maxX
                let offsetWidth = ((globalMaxX * self.scale) - globalMaxX) / 2
                let newDraggedWidth = self.draggedSize.width * self.scale
                if (newDraggedWidth > offsetWidth) {
                    self.draggedSize = CGSize(
                        width: offsetWidth / self.scale,
                        height: value.translation.height + self.previousDragged.height
                        )
                } else if (newDraggedWidth < -offsetWidth) {
                    self.draggedSize = CGSize(
                        width: -offsetWidth / self.scale,
                        height: value.translation.height + self.previousDragged.height
                        )
                } else {
                    self.draggedSize = CGSize(
                        width: value.translation.width + self.previousDragged.width,
                        height: value.translation.height + self.previousDragged.height
                        )
                }
                self.previousDragged = self.draggedSize
                }))).gesture(MagnificationGesture()
                .onChanged({ (scale) in
                self.scale = scale.magnitude
            }).onEnded({ (scaleFinal) in
                self.scale = scaleFinal.magnitude
            }))
        }
    }
}
