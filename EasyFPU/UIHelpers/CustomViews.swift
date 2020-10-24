//
//  CustomViews.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct CustomTextField: View {
    var titleKey: String
    @Binding var text: String
    var keyboardType: UIKeyboardType
    
    var body: some View {
        if #available(iOS 14.0, *) {
            return AnyView(TextField(NSLocalizedString(titleKey, comment: ""), text: $text).ignoresSafeArea(.keyboard, edges: .bottom).keyboardType(keyboardType))
        } else {
            // Fallback on earlier versions
            return AnyView(TextField(titleKey, text: $text).keyboardType(keyboardType))
        }
    }
}
