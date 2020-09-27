//
//  SheetState.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 24.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Combine

class SheetState<State>: ObservableObject {
    @Published var isShowing = false
    @Published var state: State? {
        didSet { isShowing = state != nil }
    }
}
