//
//  MealDetailSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 08.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

enum ActiveMealDetailSheet {
    case help, exportToHealth
}

struct MealDetailSheet: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    var activeSheet: ActiveMealDetailSheet
    @Binding var isPresented: Bool
    var meal: MealViewModel
    var absorptionScheme: AbsorptionScheme
    var helpScreen: HelpScreen
    
    var body: some View {
        switch activeSheet {
        case .help:
            return AnyView(
                HelpView(isPresented: self.$isPresented, helpScreen: self.helpScreen)
            )
        case .exportToHealth:
            return AnyView(
                MealExportView(isPresented: self.$isPresented, meal: meal, absorptionScheme: absorptionScheme)
            )
        }
    }
}
