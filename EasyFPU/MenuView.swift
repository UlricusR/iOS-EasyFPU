//
//  MenuView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 06.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct MenuView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    var draftAbsorptionScheme: AbsorptionSchemeViewModel
    var absorptionScheme: AbsorptionScheme
    var filePicked: (URL) -> ()
    var exportDirectory: (URL) -> ()
    @State private var activeSheet: MenuViewSheets.State?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                // Absorption Scheme
                Button(action: {
                    activeSheet = .editAbsorptionScheme
                }) {
                    Text("App Settings")
                }
                .padding(.top, 50)
                
                // Import
                Button(action: {
                    activeSheet = .pickFileToImport
                }) {
                    Text("Import from JSON")
                }
                .padding(.top, 40)
                
                // Export
                Button(action: {
                    activeSheet = .pickExportDirectory
                }) {
                    Text("Export to JSON")
                }
                .padding(.top, 15)
                
                // About
                Button(action: {
                    activeSheet = .about
                }) {
                    Text("About")
                }
                .padding(.top, 40)
                
                // Disclaimer
                Button(action: {
                    if !UserSettings.set(UserSettings.UserDefaultsType.bool(false, UserSettings.UserDefaultsBoolKey.disclaimerAccepted), errorMessage: &alertMessage) {
                        self.showingAlert = true
                    }
                    
                    // Display disclaimer
                    UserSettings.shared.disclaimerAccepted = false
                }) {
                    Text("Disclaimer")
                }
                .padding(.top, 15)
                
                // Web help
                Button(action: {
                    UIApplication.shared.open(URL(string: NSLocalizedString("Home-Link", comment: ""))!)
                }) {
                    Text("Help on the Web")
                }
                .padding(.top, 15)
                
                Spacer()
            }
            .navigationBarTitle("Settings")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $activeSheet) {
            sheetContent($0)
        }
        .alert(isPresented: self.$showingAlert) {
            Alert(
                title: Text("Notice"),
                message: Text(self.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    @ViewBuilder
    private func sheetContent(_ state: MenuViewSheets.State) -> some View {
        switch state {
        case .editAbsorptionScheme:
            SettingsEditor(draftAbsorptionScheme: self.draftAbsorptionScheme, editedAbsorptionScheme: absorptionScheme)
                    .environment(\.managedObjectContext, managedObjectContext)
        case .pickFileToImport:
            FilePickerView(callback: filePicked, documentTypes: [UTType.json])
        case .pickExportDirectory:
            FilePickerView(callback: exportDirectory, documentTypes: [UTType.folder])
        case .about:
            AboutView()
        }
    }
}
