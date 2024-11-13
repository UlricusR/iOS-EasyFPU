//
//  CountryPickerView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29/09/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import CountryPicker

struct CountryPickerView: View {
    @Binding var selectedCountry: Country
    
    var body: some View {
        VStack {
            VStack {
                Text("Select food database country")
                    .font(.title)
                    .bold()
                    .padding(20)

                HStack {
                    Text(selectedCountry.countryCode)
                    Image(uiImage: selectedCountry.flag ?? .init())
                        .resizable()
                        .frame(width: 40, height: 25)
                }.padding(20)
            }
            CountryPickerWheelView(selectedCountry: $selectedCountry)
        }.padding()
    }
}
