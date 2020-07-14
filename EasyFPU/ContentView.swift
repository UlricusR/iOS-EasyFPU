//
//  ContentView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 11.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodList: View {
    //@Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: FoodItem.getAllFoodItems()) var foodItems: FetchedResults<FoodItem>
    
    @State var showingSheet = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(foodItems, id: \.self) { foodItem in
                    FoodItemView(name: foodItem.name)
                }
            }
            .navigationBarTitle("Food List")
            .navigationBarItems(leading: EditButton(), trailing: Button(action: {
                self.showingSheet = true
            }) {
                Image(systemName: "plus.circle")
                    .imageScale(.large)
                    .foregroundColor(.green)
            })
        }
        .sheet(isPresented: $showingSheet) {
            FoodItemEditor(isPresented: self.$showingSheet, draftFoodItem: FoodItem())
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
