//
//  AboutView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Calculates carbs, extended carbs (aka. eCarbs or Fake Carbs) and the matching absorption time for individual food or a whole meal.").padding()
                Text("It's free and open-source, so I'll never ask you for money.").padding()
                Text("Documentation on rueth.info")
                    .padding().foregroundStyle(.blue)
                    .onTapGesture {
                        UIApplication.shared.open(URL(string: NSLocalizedString("Home-Link", comment: ""))!)
                    }
                Text("Version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) Build \(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)").padding()
                
                Spacer()
            }
            .navigationBarTitle(Text("About this app"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
        }
    }
}
