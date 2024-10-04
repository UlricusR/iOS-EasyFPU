//
//  RecipeListView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30/09/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct RecipeListView: View {
    enum NotificationState {
        case successfullySavedNewFoodItem(String)
        case successfullySavedNewComposedFoodItemOnly(String)
        case successfullyUpdatedFoodItem(String)
        case successfullyUpdatedComposedFoodItemOnly(String)
        case errorMessage(String)
    }
    @State private var notificationState: NotificationState?
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @ObservedObject var composedFoodItem: ComposedFoodItemViewModel
    var helpSheet: RecipeListViewSheets.State
    @State private var searchString = ""
    @State private var showFavoritesOnly = false
    @State private var activeSheet: RecipeListViewSheets.State?
    
    @FetchRequest(
        entity: ComposedFoodItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ComposedFoodItem.name, ascending: true)
        ]
    ) var composedFoodItems: FetchedResults<ComposedFoodItem>
    
    private var filteredComposedFoodItems: [ComposedFoodItemViewModel] {
        if searchString == "" {
            return showFavoritesOnly ? composedFoodItems.map { ComposedFoodItemViewModel(from: $0) } .filter { $0.favorite } : composedFoodItems.map { ComposedFoodItemViewModel(from: $0) }
        } else {
            return showFavoritesOnly ? composedFoodItems.map { ComposedFoodItemViewModel(from: $0) } .filter { $0.favorite && $0.name.lowercased().contains(searchString.lowercased()) } : composedFoodItems.map { ComposedFoodItemViewModel(from: $0) } .filter { $0.name.lowercased().contains(searchString.lowercased()) }
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            NavigationStack {
                VStack {
                    if composedFoodItems.isEmpty {
                        // No recipe yet, so display info and a call for action button
                        Image("cooking-book-color").padding()
                        Text("Oops! No recipe yet! Then let's go!").padding()
                        Button {
                            // Reset the shared ComposedViewVM
                            UserSettings.shared.composedProduct.clear()
                            
                            // Start new recipe
                            activeSheet = .createRecipe
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .imageScale(.large)
                                    .foregroundColor(.green)
                                    .bold()
                                Text("Start cooking or baking")
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(.yellow)
                            )
                        }
                    } else {
                        List {
                            ForEach(self.filteredComposedFoodItems) { composedFoodItem in
                                RecipeView(
                                    composedFoodItemVM: composedFoodItem,
                                    notificationState: $notificationState
                                )
                                .environment(\.managedObjectContext, self.managedObjectContext)
                            }
                        }
                    }
                }
                .navigationBarTitle("Recipes")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                self.activeSheet = helpSheet
                            }
                        }) {
                            Image(systemName: "questionmark.circle")
                                .imageScale(.large)
                        }
                        
                        Button(action: {
                            // Reset the shared ComposedViewVM
                            UserSettings.shared.composedProduct.clear()
                            
                            activeSheet = .createRecipe
                        }) {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.green)
                                .imageScale(.large)
                        }
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            withAnimation {
                                self.showFavoritesOnly.toggle()
                            }
                        }) {
                            if self.showFavoritesOnly {
                                Image(systemName: "star.fill")
                                    .foregroundColor(Color.yellow)
                                    .imageScale(.large)
                            } else {
                                Image(systemName: "star")
                                    .foregroundColor(Color.blue)
                                    .imageScale(.large)
                            }
                        }
                    }
                }
            }
            .searchable(text: self.$searchString)
            .navigationViewStyle(StackNavigationViewStyle())
            .sheet(item: $activeSheet) {
                sheetContent($0)
            }
            
            // Notification
            if notificationState != nil {
                NotificationView {
                    notificationViewContent()
                }
            }
        }
    }
    
    @ViewBuilder
    private func notificationViewContent() -> some View {
        switch notificationState {
        case .successfullySavedNewFoodItem(let name):
            HStack {
                Text("'\(name)' \(NSLocalizedString("successfully saved in Products", comment: ""))")
            }
            .onAppear() {
                Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { timer in
                    self.notificationState = nil
                }
            }
        case .successfullySavedNewComposedFoodItemOnly(let name):
            HStack {
                Text("'\(name)' \(NSLocalizedString("successfully saved as Recipe", comment: ""))")
            }
            .onAppear() {
                Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { timer in
                    self.notificationState = nil
                }
            }
        case .successfullyUpdatedFoodItem(let name):
            HStack {
                Text("'\(name)' \(NSLocalizedString("successfully updated in Products", comment: ""))")
            }
            .onAppear() {
                Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { timer in
                    self.notificationState = nil
                }
            }
        case .successfullyUpdatedComposedFoodItemOnly(let name):
            HStack {
                Text("'\(name)' \(NSLocalizedString("successfully updated as Recipe", comment: ""))")
            }
            .onAppear() {
                Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { timer in
                    self.notificationState = nil
                }
            }
        case .errorMessage(let message):
            HStack {
                Text(message)
            }
            .onAppear() {
                Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { timer in
                    self.notificationState = nil
                }
            }
        case .none:
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: RecipeListViewSheets.State) -> some View {
        switch state {
        case .createRecipe:
            FoodItemComposerView(
                composedFoodItemVM: UserSettings.shared.composedProduct,
                notificationState: $notificationState)
        case .recipeListHelp:
            HelpView(helpScreen: .recipeList)
        }
    }
}
