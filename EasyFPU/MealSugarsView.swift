//
//  MealSugarsView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 22.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct MealSugarsView: View {
    var meal: MealViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .center) {
                Image(systemName: "cube.fill")
                Text("Sugars").font(.headline).fontWeight(.bold).lineLimit(2)
            }
            .multilineTextAlignment(.center)
            .foregroundColor(.red)
            .padding(.trailing)
            
            VStack(alignment: .trailing) { // Questions
                Text("How much?")
                Text("When?")
                Text("How long?")
            }.foregroundColor(.red)
            
            VStack(alignment: .leading) { // Answers
                HStack { // How much?
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.sugars))!)
                    Text("g Carbs")
                }
                HStack { // When?
                    Text("Now at")
                    Text(ChartBar.timeStyle.string(from: Date()))
                }
                Text("All at once") // How long?
            }
        }
    }
}
