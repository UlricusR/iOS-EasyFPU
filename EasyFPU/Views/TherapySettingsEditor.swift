//
//  AbsorptionSchemeEditor.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 30.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import CountryPicker

struct TherapySettingsEditor: View {
    @Binding var navigationPath: NavigationPath
    @ObservedObject var absorptionScheme: AbsorptionSchemeViewModel
    @ObservedObject var userSettings = UserSettings.shared
    @State private var errorMessage: String = ""
    @State private var showingAlert: Bool = false
    @State private var showingScreen = false
    private let helpScreen = HelpScreen.absorptionSchemeEditor
    
    var body: some View {
        Form {
            AbsorptionParameterSettingsView(
                draftAbsorptionScheme: absorptionScheme,
                errorMessage: $errorMessage,
                showingAlert: $showingAlert
            )
            AbsorptionBlockSettingsView(
                absorptionScheme: absorptionScheme,
                errorMessage: $errorMessage,
                showingAlert: $showingAlert
            )
            
        }
        // Navigation bar
        .navigationTitle(Text("Therapy Settings"))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.showingScreen = true
                }) {
                    Image(systemName: "questionmark.circle")
                        .imageScale(.large)
                }
                .accessibilityIdentifierLeaf("HelpButton")
            }
        }
        .alert("Data alert", isPresented: self.$showingAlert, actions: {}, message: { Text(self.errorMessage) })
        .sheet(isPresented: self.$showingScreen) {
            HelpView(helpScreen: self.helpScreen)
                .accessibilityIdentifierBranch("HelpSettingsEditor")
        }
    }
}
