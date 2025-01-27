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
    @State private var activeAlert: SimpleAlertType?
    @State private var showingAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
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
                }
                
                // The overlaying Accept and Decline buttons
                VStack {
                    Spacer()
                    HStack {
                        // The Decline button
                        Button {
                            var settingsError = ""
                            if !UserSettings.set(UserSettings.UserDefaultsType.bool(false, UserSettings.UserDefaultsBoolKey.disclaimerAccepted), errorMessage: &settingsError) {
                                activeAlert = .fatalError(message: settingsError)
                            } else {
                                // Display alert
                                activeAlert = .notice(message: "You need to accept the disclaimer to continue.")
                            }
                            self.showingAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "xmark.circle.fill").imageScale(.large).foregroundStyle(.red)
                                Text("Decline")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .buttonStyle(ActionButton())
                        .accessibilityIdentifierLeaf("DeclineButton")
                        
                        // The Accept button
                        Button {
                            var settingsError = ""
                            if !UserSettings.set(UserSettings.UserDefaultsType.bool(true, UserSettings.UserDefaultsBoolKey.disclaimerAccepted), errorMessage: &settingsError) {
                                activeAlert = .fatalError(message: settingsError)
                                self.showingAlert = true
                            }
                            
                            // Set dynamic variable and broadcast change in UserSettings
                            UserSettings.shared.disclaimerAccepted = true
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill").imageScale(.large).foregroundStyle(.green)
                                Text("Accept")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .buttonStyle(ActionButton())
                        .accessibilityIdentifierLeaf("AcceptButton")
                    }
                    .padding()
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .navigationTitle(Text("Disclaimer"))
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
