//
//  FoodListSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 14.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

enum ActiveMenuViewSheet {
    case editAbsorptionScheme, pickFileToImport
}

struct MenuViewSheets: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    var activeSheet: ActiveMenuViewSheet
    @Binding var isPresented: Bool
    var draftAbsorptionScheme: AbsorptionSchemeViewModel
    var absorptionScheme: AbsorptionScheme
    var callback: (URL) -> ()
    
    var body: some View {
        switch activeSheet {
        case .editAbsorptionScheme:
            return AnyView(
                AbsorptionSchemeEditor(isPresented: self.$isPresented, draftAbsorptionScheme: self.draftAbsorptionScheme, editedAbsorptionScheme: absorptionScheme)
                    .environment(\.managedObjectContext, managedObjectContext)
            )
        case .pickFileToImport:
            return AnyView(
                FilePickerView(callback: callback)
            )
        }
    }
}
