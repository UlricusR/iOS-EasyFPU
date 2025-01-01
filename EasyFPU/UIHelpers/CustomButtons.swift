//
//  ColorModels.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 01/01/2025.
//  Copyright © 2025 Ulrich Rüth. All rights reserved.
//

import SwiftUI

//
// Buttons
//

struct StandardButton: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .background(.blue)
            .cornerRadius(10)
            .saturation(isEnabled ? 1 : 0)
    }
}

struct CallToActionButton: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.blue)
            .background(.yellow)
            .cornerRadius(20)
            .saturation(isEnabled ? 1 : 0)
    }
}
