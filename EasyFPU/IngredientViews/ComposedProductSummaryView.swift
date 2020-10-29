//
//  ComposedProductSummaryView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct ComposedProductSummaryView: View {
    @Binding var activeIngredientsListSheet: IngredientsListSheets.State?
    @ObservedObject var product: ComposedProductViewModel
    
    var body: some View {
        Divider()
        
        HStack {
            Button(action: {
                product.clear()
            }) {
                Image(systemName: "xmark.circle").foregroundColor(.red).imageScale(.large).padding([.leading, .trailing])
            }
            
            Text("Composed product").font(.headline).multilineTextAlignment(.center)
        
            Button(action: {
                activeIngredientsListSheet = .composedProductDetail
            }) {
                Image(systemName: "info.circle").imageScale(.large).foregroundColor(.accentColor).padding([.leading, .trailing])
            }
        }
        
        List {
            ForEach(product.foodItems) { foodItem in
                HStack {
                    Text(DataHelper.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: foodItem.amount))!)
                    Text("g")
                    Text(foodItem.name)
                }
            }
        }
        .font(.caption)
        .padding()
    }
}
