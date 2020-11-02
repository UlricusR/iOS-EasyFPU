//
//  DecodableRemoteContent.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 26.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation
import Combine

final class DecodableRemoteContent<Value, Decoder>: RemoteContent where Value: Decodable, Decoder: TopLevelDecoder, Decoder.Input == Data {
    unowned let urlSession: URLSession
    let url: URL
    let type: Value.Type
    let decoder: Decoder
    
    init(urlSession: URLSession = .shared, url: URL, type: Value.Type, decoder: Decoder) {
        self.urlSession = urlSession
        self.url = url
        self.type = type
        self.decoder = decoder
    }
    
    @Published private(set) var loadingState: RemoteContentLoadingState<Value> = .initial
    
    func load() {
        // Set state to in progress
        loadingState = .inProgress
        
        // Start loading
        cancellable = urlSession
            .dataTaskPublisher(for: url)
            .map {
                $0.data
            }
            .decode(type: type, decoder: decoder)
            .map {
                .success($0)
            }
            .catch {
                Just(.failure($0))
            }
            .receive(on: RunLoop.main)
            .assign(to: \.loadingState, on: self)
    }
    
    func cancel() {
        // Reset loading state
        loadingState = .initial
        
        // Stop loading
        cancellable?.cancel()
        cancellable = nil
    }
    
    private var cancellable: AnyCancellable?
}
