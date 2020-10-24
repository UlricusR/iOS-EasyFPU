//
//  CountryPicker.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 24.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import ADCountryPicker

struct CountryPicker: UIViewControllerRepresentable {
    @Binding var code: String
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CountryPicker>) -> ADCountryPicker {
        let picker = ADCountryPicker()
        
        // Customize picker
        picker.pickerTitle = NSLocalizedString("Select food database country", comment: "")
        picker.searchBarBackgroundColor = .white
        picker.didSelectCountryClosure = { name, code in
            self.code = code
        }
        
        // Return picker
        return picker
    }
    
    func updateUIViewController(_ uiViewController: ADCountryPicker, context: UIViewControllerRepresentableContext<CountryPicker>) {
        // Nothing to do
    }
    
    typealias UIViewControllerType = ADCountryPicker
}
