//
//  RemoteImage.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 27.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation
import Combine

public final class RemoteImage: RemoteContent {
    public enum Error: Swift.Error {
        case decode
    }
    
    public unowned let urlSession: URLSession
    public let url: URL
    
    public init(urlSession: URLSession = .shared, url: URL) {
        self.urlSession = urlSession
        self.url = url
    }
    
    @Published private(set) public var loadingState: RemoteContentLoadingState<UIImage, Float?> = .initial
    
}
