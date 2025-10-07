//
//  FoodImage.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 07/10/2025.
//  Copyright © 2025 Ulrich Rüth. All rights reserved.
//
//  Related tutorial: https://www.kien-hoang.com/p/zooming-dragging-rotating-image-in-swiftui/
//

import SwiftUI

struct FoodImage: View {
    let url: URL
    let name: String
    
    @State private var scale = 1.0
    @State private var lastScale = 1.0
    private let minScale = 1.0
    private let maxScale = 5.0
    
    @State private var offset = CGSize.zero
    @State private var lastOffset = CGSize.zero
    
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    magnification
                        .simultaneously(with: dragging)
                )
        } placeholder: {
            Color.gray
        }
        .navigationTitle(name)
    }
}

// MARK: - Zoom
private extension FoodImage {
    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { state in
                adjustScale(from: state)
            }
            .onEnded { _ in
                withAnimation {
                    validateScaleLimits()
                }
                lastScale = 1.0
            }
    }
    
    private func adjustScale(from state: MagnificationGesture.Value) {
        let delta = state / lastScale
        scale *= delta
        lastScale = state
    }
    
    private func getMinimumScaleAllowed() -> CGFloat {
        return max(scale, minScale)
    }
    
    private func getMaximumScaleAllowed() -> CGFloat {
        return min(scale, maxScale)
    }
    
    private func validateScaleLimits() {
        scale = getMinimumScaleAllowed()
        scale = getMaximumScaleAllowed()
    }
}

// MARK: - Drag
private extension FoodImage {
    var dragging: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                withAnimation(.interactiveSpring()) {
                    offset = handleOffsetChange(value.translation)
                }
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }
    
    private func handleOffsetChange(_ offset: CGSize) -> CGSize {
        var newOffset: CGSize = .zero
        
        newOffset.width = offset.width + lastOffset.width
        newOffset.height = offset.height + lastOffset.height
        
        return newOffset
    }
}
