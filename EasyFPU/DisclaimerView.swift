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
        NavigationView {
            VStack(alignment: .leading) {
                Text("Applying the nutrition information calculated by this app in a diabetes therapy may bear the risk of high or low blood glucose values. Use at your own risk!").padding()
                Text("Please consult your medical doctor before modifying your diabetes therapy and applying Fat Protein Units.").padding().foregroundColor(.red).font(.headline)
                Text("Read more here!")
                .padding().foregroundColor(.accentColor)
                .onTapGesture {
                    UIApplication.shared.open(URL(string: NSLocalizedString("Home-Link", comment: ""))!)
                }
                
                Text("Declining will not let you continue to use the app.").padding()
                Spacer()
            }
            .navigationBarTitle(Text("Disclaimer"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        var settingsError = ""
                        if !UserSettings.set(UserSettings.UserDefaultsType.bool(false, UserSettings.UserDefaultsBoolKey.disclaimerAccepted), errorMessage: &settingsError) {
                            self.alertTitle = "Notice"
                            self.alertMessage = settingsError
                        } else {
                            // Display alert
                            self.alertTitle = "Disclaimer"
                            self.alertMessage = "You need to accept the disclaimer to continue."
                        }
                        self.showingAlert = true
                    }) {
                        Text("Decline")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        var settingsError = ""
                        if !UserSettings.set(UserSettings.UserDefaultsType.bool(true, UserSettings.UserDefaultsBoolKey.disclaimerAccepted), errorMessage: &settingsError) {
                            self.alertTitle = "Notice"
                            self.alertMessage = settingsError
                            self.showingAlert = true
                        }
                        
                        // Set dynamic variable and broadcast change in UserSettings
                        UserSettings.shared.disclaimerAccepted = true
                    }) {
                        Text("Accept")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(isPresented: self.$showingAlert) {
            Alert(
                title: Text(self.alertTitle),
                message: Text(self.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
