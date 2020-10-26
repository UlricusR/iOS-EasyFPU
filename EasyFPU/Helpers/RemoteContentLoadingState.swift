//
//  RemoteContentLoader.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 26.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation
import Combine

enum RemoteContentLoadingState<Value> {
    case initial
    case inProgress
    case success(_ value: Value)
    case failure(_ error: Error)
}
