//
//  ComposedProductDetail.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 29.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct ComposedProductDetail: View {
    var product: ComposedProductViewModel
    
    var body: some View {
        Text(product.name)
    }
}
