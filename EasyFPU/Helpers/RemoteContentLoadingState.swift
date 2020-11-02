//
//  RemoteContentLoader.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 26.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation
import Combine

public enum RemoteContentLoadingState<Value, Progress> {
    case initial
    case inProgress(_ progress: Progress)
    case success(_ value: Value)
    case failure(_ error: Error)
}

public extension RemoteContentLoadingState {
    var isInProgress: Bool {
        switch self {
        case .inProgress:
            return true
        default:
            return false
        }
    }
}
