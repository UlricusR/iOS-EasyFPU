//
//  AboutView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Calculates carbs, extended carbs (aka. eCarbs or Fake Carbs) and the matching absorption time for individual food or a whole meal.").padding()
                Text("Documentation on rueth.info").padding()
                Spacer()
            }
            .navigationBarTitle(Text("About this app"))
            .navigationBarItems(trailing: Button(action: {
                self.isPresented = false
            }) {
                Text("Done")
            })
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
