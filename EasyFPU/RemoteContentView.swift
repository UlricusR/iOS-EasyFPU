//
//  PreviewImageView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 26.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import Combine

struct RemoteContentView<Value, Empty, Progress, Failure, Content>: View where
    Empty: View,
    Progress: View,
    Failure: View,
    Content: View
{
    let empty: () -> Empty
    let progress: () -> Progress
    let failure: (_ error: Error, _ retry: @escaping () -> Void) -> Failure
    let content: (_ value: Value) -> Content
    
    init<R: RemoteContent>(remoteContent: R,
                           empty: @escaping () -> Empty,
                           progress: @escaping () -> Progress,
                           failure: @escaping (_ error: Error, _ retry: @escaping () -> Void) -> Failure,
                           content: @escaping (_ value: Value) -> Content) where R.ObjectWillChangePublisher == ObservableObjectPublisher, R.Value == Value
    {
        self.remoteContent = AnyRemoteContent(remoteContent)
        
        self.empty = empty
        self.progress = progress
        self.failure = failure
        self.content = content
    }
    
    var body: some View {
        ZStack {
            switch remoteContent.loadingState {
            case .initial:
                empty()
            case .inProgress:
                progress()
            case .success(let value):
                content(value)
            case .failure(let error):
                failure(error) {
                    remoteContent.load()
                }
            }
        }
        .onAppear {
            remoteContent.load()
        }
        .onDisappear {
            remoteContent.cancel()
        }
    }
    
    @ObservedObject private var remoteContent: AnyRemoteContent<Value>
}
