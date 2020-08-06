//
//  MenuView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 06.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    var draftAbsorptionScheme: AbsorptionSchemeViewModel
    var absorptionScheme: AbsorptionScheme
    @State var activeSheet = ActiveMenuViewSheet.editAbsorptionScheme
    @State var showingSheet = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                self.activeSheet = ActiveMenuViewSheet.editAbsorptionScheme
                self.showingSheet = true
            }) {
                Text("Absorption scheme")
            }
                .foregroundColor(.gray)
                .padding(.top, 100)
            Text("Import from JSON")
                .foregroundColor(.gray)
                .padding(.top, 80)
            Text("Export to JSON")
                .foregroundColor(.gray)
                .padding(.top, 30)
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 32/255, green: 32/255, blue: 32/255))
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: self.$showingSheet) {
            MenuViewSheets(
                activeSheet: self.activeSheet,
                isPresented: self.$showingSheet,
                draftAbsorptionScheme: AbsorptionSchemeViewModel(from: self.absorptionScheme),
                absorptionScheme: self.absorptionScheme
            )
            .environment(\.managedObjectContext, self.managedObjectContext)
        }
    }
}
