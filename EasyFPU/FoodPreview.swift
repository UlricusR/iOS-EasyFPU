//
//  FoodPreview.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 21.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import RemoteContentView

struct FoodPreview: View {
    var selectedEntry: FoodDatabaseEntry
    @ObservedObject var draftFoodItem: FoodItemViewModel
    @Environment(\.presentationMode) var presentation
    @State private var errorMessage = ""
    @State private var showingAlert = false
    @State private var activeSheet: FoodPreviewSheets.State?
    
    var body: some View {
        NavigationView {
            VStack {
                // The food name
                Text(selectedEntry.name).font(.headline).padding()
                
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
                
                Spacer()
            }
            .navigationBarTitle("Scanned Food")
            .navigationBarItems(leading: Button(action: {
                // Just close sheet
                presentation.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            }, trailing: Button(action: {
                draftFoodItem.fill(with: selectedEntry)
                    
                // Close sheet
                presentation.wrappedValue.dismiss()
                
            }) {
                Text("Select")
            })
        }
        .alert(isPresented: self.$showingAlert) {
            Alert(
                title: Text("Data alert"),
                message: Text(self.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .sheet(item: $activeSheet) {
            sheetContent($0)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    @ViewBuilder
    private func getThumbView(image: FoodDatabaseImage?) -> some View {
        if image != nil {
            let remoteImage = RemoteImage(url: image!.thumb)
            RemoteContentView(remoteContent: remoteImage) {
                Image(uiImage: $0)
            }
        }
    }
    
    @ViewBuilder
    private func getImageView(image: FoodDatabaseImage?) -> some View {
        if image != nil {
            let remoteImage = RemoteImage(url: image!.image)
            RemoteContentView(remoteContent: remoteImage) {
                Image(uiImage: $0)
            }
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: FoodPreviewSheets.State) -> some View {
        switch state {
        case .front:
            if selectedEntry.imageFront != nil {
                let remoteImage = RemoteImage(url: selectedEntry.imageFront!.image)
                NavigationView {
                    RemoteContentView(remoteContent: remoteImage) {
                        Image(uiImage: $0)
                    }
                    .navigationBarTitle(selectedEntry.name)
                    .navigationBarItems(trailing: Button(action: {
                        self.activeSheet = nil
                    }) {
                        Text("Done")
                    })
                }
            }
        case .nutriments:
            if selectedEntry.imageNutriments != nil {
                let remoteImage = RemoteImage(url: selectedEntry.imageNutriments!.image)
                NavigationView {
                    RemoteContentView(remoteContent: remoteImage) {
                        Image(uiImage: $0)
                    }
                    .navigationBarTitle(selectedEntry.name)
                    .navigationBarItems(trailing: Button(action: {
                        self.activeSheet = nil
                    }) {
                        Text("Done")
                    })
                }
            }
        }
    }
}
