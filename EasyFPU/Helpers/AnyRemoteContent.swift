//
//  AnyRemoteContent.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 26.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation
import Combine

final class AnyRemoteContent<Value>: RemoteContent {
    init<R: RemoteContent>(_ remoteContent: R) where R.ObjectWillChangePublisher == ObjectWillChangePublisher, R.Value == Value {
        objectWillChangeClosure = {
            remoteContent.objectWillChange
        }
        
        loadingStateClosure = {
            remoteContent.loadingState
        }
        
        loadClosure = {
            remoteContent.load()
        }
        
        cancelClosure = {
            remoteContent.cancel()
        }
    }
    
    private let objectWillChangeClosure: () -> ObjectWillChangePublisher
    
    var objectWillChange: ObservableObjectPublisher {
        objectWillChangeClosure()
    }
    
    private let loadingStateClosure: () -> RemoteContentLoadingState<Value>
    
    var loadingState: RemoteContentLoadingState<Value> {
        loadingStateClosure()
    }
    
    private let loadClosure: () -> Void
    
    func load() {
        loadClosure()
    }
    
    private let cancelClosure: () -> Void
    
    func cancel() {
        cancelClosure()
    }
}
