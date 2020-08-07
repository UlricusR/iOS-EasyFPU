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
    @State var showingAlert = false
    @State var alertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            // Absorption Scheme
            Button(action: {
                self.activeSheet = ActiveMenuViewSheet.editAbsorptionScheme
                self.showingSheet = true
            }) {
                Text("Absorption scheme")
            }
            .foregroundColor(.gray)
            .padding(.top, 100)
            
            // Import
            Button(action: {
                self.activeSheet = ActiveMenuViewSheet.pickFileToImport
                self.showingSheet = true
            }) {
                Text("Import from JSON")
            }
            .foregroundColor(.gray)
            .padding(.top, 80)
            
            // Export
            Button(action: {
                if DataHelper.exportFoodItems() {
                    self.alertMessage = NSLocalizedString("Successfully exported food list", comment: "")
                    self.showingAlert = true
                } else {
                    self.alertMessage = NSLocalizedString("Failed to export food list", comment: "")
                    self.showingAlert = true
                }
            }) {
                Text("Export to JSON")
            }
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
                absorptionScheme: self.absorptionScheme,
                callback: self.filePicked
            )
            .environment(\.managedObjectContext, self.managedObjectContext)
        }
        .alert(isPresented: self.$showingAlert) {
            Alert(
                title: Text("Notice"),
                message: Text(self.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func filePicked(_ url: URL) {
        debugPrint("Filename: \(url)")
    }
}