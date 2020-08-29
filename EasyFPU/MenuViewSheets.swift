//
//  FoodListSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 14.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import MobileCoreServices

enum ActiveMenuViewSheet {
    case editAbsorptionScheme, pickFileToImport, pickExportDirectory, about
}

struct MenuViewSheets: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    var activeSheet: ActiveMenuViewSheet
    @Binding var isPresented: Bool
    var draftAbsorptionScheme: AbsorptionSchemeViewModel
    var absorptionScheme: AbsorptionScheme
    var filePicked: (URL) -> ()
    var exportDirectory: (URL) -> ()
    
    var body: some View {
        switch activeSheet {
        case .editAbsorptionScheme:
            return AnyView(
                AbsorptionSchemeEditor(isPresented: self.$isPresented, draftAbsorptionScheme: self.draftAbsorptionScheme, editedAbsorptionScheme: absorptionScheme)
                    .environment(\.managedObjectContext, managedObjectContext)
            )
        case .pickFileToImport:
            return AnyView(
                FilePickerView(callback: filePicked, documentTypes: [kUTTypeText as String])
            )
        case .pickExportDirectory:
            return AnyView(
                FilePickerView(callback: exportDirectory, documentTypes: [kUTTypeFolder as String])
            )
        case .about:
            return AnyView(
                AboutView(isPresented: self.$isPresented)
            )
        }
    }
}
