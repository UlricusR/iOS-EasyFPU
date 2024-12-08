//
//  BannerService.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 07/12/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import Foundation
import SwiftUI

class BannerService: ObservableObject {
    @Published var isAnimating = false
    @Published var dragOffset = CGSize.zero
    @Published var bannerType: BannerType? {
        didSet {
            withAnimation {
                switch bannerType {
                case .none:
                    isAnimating = false
                case .some:
                    isAnimating = true
                }
            }
        }
    }
    let maxDragOffsetHeight: CGFloat = -50.0
    
    func setBanner(banner: BannerType) {
        withAnimation {
            self.bannerType = banner
        }
    }

    func removeBanner() {
        withAnimation {
            self.bannerType = nil
            self.isAnimating = false
            self.dragOffset = .zero
        }
    }
}
