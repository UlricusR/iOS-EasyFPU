//
//  DisclaimerView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct DisclaimerView: View {
    @Environment(\.presentationMode) var presentation
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Applying the nutrition information calculated by this app in a diabetes therapy may bear the risk of high or low blood glucose values. Use at your own risk!").padding()
                Text("Please consult your medical doctor before modifying your diabetes therapy and applying Fat Protein Units.").padding().foregroundStyle(.red).font(.headline)
                Text("Read more here!")
                    .padding().foregroundStyle(.blue)
                    .onTapGesture {
                        UIApplication.shared.open(URL(string: NSLocalizedString("Home-Link", comment: ""))!)
                    }
                    .accessibilityIdentifierLeaf("LinkToDisclaimer")
                
                Text("Declining will not let you continue to use the app.").padding()
                Spacer()
            }
            .navigationTitle(Text("Disclaimer"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Decline") {
                        var settingsError = ""
                        if !UserSettings.set(UserSettings.UserDefaultsType.bool(false, UserSettings.UserDefaultsBoolKey.disclaimerAccepted), errorMessage: &settingsError) {
                            self.alertTitle = NSLocalizedString("Notice", comment: "")
                            self.alertMessage = settingsError
                        } else {
                            // Display alert
                            self.alertTitle = NSLocalizedString("Disclaimer", comment: "")
                            self.alertMessage = NSLocalizedString("You need to accept the disclaimer to continue.", comment: "")
                        }
                        self.showingAlert = true
                    }
                    .accessibilityIdentifierLeaf("DeclineButton")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Accept") {
                        var settingsError = ""
                        if !UserSettings.set(UserSettings.UserDefaultsType.bool(true, UserSettings.UserDefaultsBoolKey.disclaimerAccepted), errorMessage: &settingsError) {
                            self.alertTitle = NSLocalizedString("Notice", comment: "")
                            self.alertMessage = settingsError
                            self.showingAlert = true
                        }
                        
                        // Set dynamic variable and broadcast change in UserSettings
                        UserSettings.shared.disclaimerAccepted = true
                    }
                    .accessibilityIdentifierLeaf("AcceptButton")
                }
            }
        }
        .alert(self.alertTitle, isPresented: self.$showingAlert, actions: {}, message: { Text(self.alertMessage) })
    }
}
