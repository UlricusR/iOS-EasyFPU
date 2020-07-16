//
//  ContentView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 11.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodList: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: FoodItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \FoodItem.name, ascending: true)
        ]
    ) var foodItems: FetchedResults<FoodItem>
    @State var showingSheet = false
    @State var activeSheet = ActiveFoodListSheet.selectFoodItem
    @State var activeFoodItem: FoodItem
    
    var body: some View {
        NavigationView {
            List {
                ForEach(foodItems, id: \.self) { foodItem in
                    FoodItemView(foodItem: foodItem)
                    .onTapGesture {
                        self.activeFoodItem = foodItem
                        self.activeSheet = .selectFoodItem
                        self.showingSheet = true
                    }
                    .onLongPressGesture {
                        self.activeFoodItem = foodItem
                        self.activeSheet = .editFoodItem
                        self.showingSheet = true
                    }
                }
                .onDelete(perform: deleteFoodItem)
            }
            .navigationBarTitle("Food List")
            .navigationBarItems(trailing: Button(action: {
                self.activeFoodItem = FoodItem(context: self.managedObjectContext)
                self.activeSheet = .editFoodItem
                self.showingSheet = true
            }) {
                Image(systemName: "plus.circle")
                    .imageScale(.large)
                    .foregroundColor(.green)
            })
        }
        .sheet(isPresented: $showingSheet) {
            FoodListSheets(activeSheet: self.activeSheet, isPresented: self.$showingSheet, foodItem: self.$activeFoodItem)
        }
    }
    
    func deleteFoodItem(at offsets: IndexSet) {
        offsets.forEach { index in
            let foodItem = self.foodItems[index]
            self.managedObjectContext.delete(foodItem)
        }
        
        saveContext()
    }
    
    func saveContext() {
        if self.managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print("Error saving managed object context: \(error)")
            }
        }
    }
}
