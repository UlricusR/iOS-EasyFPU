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
    @FetchRequest(fetchRequest: FoodItem.getAllFoodItems()) var foodItems: FetchedResults<FoodItem>
    @State var showingSheet = false
    @State var activeSheet = ActiveFoodListSheet.selectFoodItem
    
    var body: some View {
        NavigationView {
            List {
                ForEach(foodItems, id: \.self) { foodItem in
                    FoodItemView(foodItem: foodItem)
                }
                .onDelete(perform: deleteMovie)
                .onTapGesture {
                    self.activeSheet = .selectFoodItem
                    self.showingSheet = true
                }
            }
            .navigationBarTitle("Food List")
            .navigationBarItems(/*leading: EditButton(),*/ trailing: Button(action: {
                self.activeSheet = .editFoodItem
                self.showingSheet = true
            }) {
                Image(systemName: "plus.circle")
                    .imageScale(.large)
                    .foregroundColor(.green)
            })
        }
        .sheet(isPresented: $showingSheet) {
            FoodListSheets(activeSheet: self.activeSheet, isPresented: self.$showingSheet)
        }
    }
    
    func deleteMovie(at offsets: IndexSet) {
        offsets.forEach { index in
            let foodItem = self.foodItems[index]
            self.managedObjectContext.delete(foodItem)
        }
        
        saveContext()
    }
    
    func saveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        FoodList()
    }
}
#endif
