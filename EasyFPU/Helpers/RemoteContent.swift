//
//  RemoteContent.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 26.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

protocol RemoteContent: ObservableObject {
    associatedtype Value
    
    var loadingState: RemoteContentLoadingState<Value> { get }
    
    func load()
    
    func cancel()
}
