//
//  MenuView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 06.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import MobileCoreServices

struct MenuView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    var draftAbsorptionScheme: AbsorptionSchemeViewModel
    var absorptionScheme: AbsorptionScheme
    var filePicked: (URL) -> ()
    var exportDirectory: (URL) -> ()
    @ObservedObject var sheet = MenuViewSheets()
    @State var showingAlert = false
    @State var alertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            // Absorption Scheme
            Button(action: {
                self.sheet.state = .editAbsorptionScheme
            }) {
                Text("Absorption scheme")
            }
            .foregroundColor(.gray)
            .padding(.top, 50)
            
            // Import
            Button(action: {
                self.sheet.state = .pickFileToImport
            }) {
                Text("Import from JSON")
            }
            .foregroundColor(.gray)
            .padding(.top, 40)
            
            // Export
            Button(action: {
                self.sheet.state = .pickExportDirectory
            }) {
                Text("Export to JSON")
            }
            .foregroundColor(.gray)
            .padding(.top, 15)
            
            // About
            Button(action: {
                self.sheet.state = .about
            }) {
                Text("About")
            }
            .foregroundColor(.gray)
            .padding(.top, 40)
            
            // Disclaimer
            Button(action: {
                self.sheet.state = .disclaimer
            }) {
                Text("Disclaimer")
            }
            .foregroundColor(.gray)
            .padding(.top, 15)
            
            // Web help
            Button(action: {
                UIApplication.shared.open(URL(string: NSLocalizedString("Home-Link", comment: ""))!)
            }) {
                Text("Help on the Web")
            }
            .foregroundColor(.gray)
            .padding(.top, 15)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 32/255, green: 32/255, blue: 32/255))
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: self.$sheet.isShowing, content: sheetContent)
        .alert(isPresented: self.$showingAlert) {
            Alert(
                title: Text("Notice"),
                message: Text(self.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    @ViewBuilder
    private func sheetContent() -> some View {
        if sheet.state != nil {
            switch sheet.state! {
            case .editAbsorptionScheme:
                AbsorptionSchemeEditor(isPresented: $sheet.isShowing, draftAbsorptionScheme: self.draftAbsorptionScheme, editedAbsorptionScheme: absorptionScheme)
                        .environment(\.managedObjectContext, managedObjectContext)
            case .pickFileToImport:
                FilePickerView(callback: filePicked, documentTypes: [kUTTypeText as String])
            case .pickExportDirectory:
                FilePickerView(callback: exportDirectory, documentTypes: [kUTTypeFolder as String])
            case .about:
                AboutView(isPresented: $sheet.isShowing)
            case .disclaimer:
                DisclaimerView(isDisplayed: $sheet.isShowing)
            }
        } else {
            EmptyView()
        }
    }
}
