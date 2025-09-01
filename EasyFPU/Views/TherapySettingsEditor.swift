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
    @State var absorptionScheme: AbsorptionScheme
    @ObservedObject var userSettings = UserSettings.shared
    @State private var activeAlert: SimpleAlertType?
    @State private var showingAlert: Bool = false
    @State private var showingScreen = false
    private let helpScreen = HelpScreen.absorptionSchemeEditor
    
    var body: some View {
        Form {
            AbsorptionParameterSettingsView(
                draftAbsorptionScheme: absorptionScheme,
                activeAlert: $activeAlert,
                showingAlert: $showingAlert
            )
            AbsorptionBlockSettingsView(
                absorptionScheme: absorptionScheme,
                activeAlert: $activeAlert,
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
        .sheet(isPresented: self.$showingScreen) {
            HelpView(helpScreen: self.helpScreen)
                .accessibilityIdentifierBranch("HelpSettingsEditor")
        }
        .alert(
            activeAlert?.title() ?? "Notice",
            isPresented: $showingAlert,
            presenting: activeAlert
        ) { activeAlert in
            activeAlert.button()
        } message: { activeAlert in
            activeAlert.message()
        }
    }
}
