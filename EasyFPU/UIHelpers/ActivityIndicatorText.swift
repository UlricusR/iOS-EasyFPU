//
//  ActivityIndicatorText.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 03.11.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct ActivityIndicatorText: View {
    var staticText: String
    @State var text = ""
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text("\(staticText)\(text)")
            .font(.system(size: 17)).bold()
            .transition(.slide)
            .onReceive(timer, perform: { (_) in
                if self.text.count == 3 {
                    self.text = ""
                } else {
                    self.text += "."
                }
            })
            .onAppear() {
                self.text = "."
            }
    }
}
