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
    var selectedEntry: FoodDatabaseEntry
    @State var activeSheet: FoodPreviewContentSheets.State?
    @State var scale: CGFloat = 1.0
    @State var isTapped: Bool = false
    @State var pointTapped: CGPoint = CGPoint.zero
    @State var draggedSize: CGSize = CGSize.zero
    @State var previousDragged: CGSize = CGSize.zero
    
    var body: some View {
        VStack {
            // The food name
            Text(selectedEntry.name).font(.headline).padding()
            
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
            }
            
            HStack {
                Text("Calories per 100g")
                Spacer()
                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: selectedEntry.caloriesPer100g.getEnergyInKcal()))!)
                Text("kcal")
            }.padding([.leading, .trailing])
            HStack {
                Text("Carbs per 100g")
                Spacer()
                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: selectedEntry.carbsPer100g))!)
                Text("g")
            }.padding([.leading, .trailing])
            HStack {
                Text("Thereof Sugars per 100g")
                Spacer()
                Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: selectedEntry.sugarsPer100g))!)
                Text("g")
            }.padding([.leading, .trailing])
            
            HStack {
                Text(NSLocalizedString("Link to entry in ", comment: "") + UserSettings.shared.foodDatabase.databaseType.rawValue)
                    .padding().foregroundColor(.accentColor)
                    .onTapGesture {
                        try? UIApplication.shared.open(UserSettings.shared.foodDatabase.getLink(for: selectedEntry.sourceId))
                    }
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
            URLImage(url: image!.thumb) { image in
                image
            }
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: FoodPreviewContentSheets.State) -> some View {
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
        URLImage(url: url) { image in
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
