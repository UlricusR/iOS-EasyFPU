//
//  AboutView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.08.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Calculates carbs, extended carbs (aka. eCarbs or Fake Carbs) and the matching absorption time for individual food or a whole meal.").padding()
                Text("It's free and open-source, so I'll never ask you for money.").padding()
                Text("Documentation on rueth.info")
                    .padding().foregroundStyle(.blue)
                    .onTapGesture {
                        UIApplication.shared.open(URL(string: NSLocalizedString("Home-Link", comment: ""))!)
                    }
                    .accessibilityIdentifierLeaf("LinkToDocumentationButton")
                Text("Version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String) Build \(Bundle.main.infoDictionary!["CFBundleVersion"] as! String)").padding()
            }
        }
        .navigationTitle(Text("About this app"))
    }
}
