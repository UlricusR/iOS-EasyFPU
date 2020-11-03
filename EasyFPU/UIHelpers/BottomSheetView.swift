//
//  BottomSheetView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 01.11.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

fileprivate enum Constants {
    static let radius: CGFloat = 16
    static let indicatorHeight: CGFloat = 6
    static let indicatorWidth: CGFloat = 60
    static let snapRatioMax: CGFloat = 0.4
    static let snapRatioMid: CGFloat = 0.1
    static let midHeightRatio: CGFloat = 0.3
    static let minHeightRatio: CGFloat = 0.15
}

fileprivate enum Position {
    case low
    case mid
    case high
}

struct BottomSheetView<Content: View>: View {
    let maxHeight: CGFloat
    let midHeight: CGFloat
    let minHeight: CGFloat
    let content: Content
    
    @GestureState private var translation: CGFloat = 0
    @State private var position: Position = .mid
    
    private var offset: CGFloat {
        switch position {
        case .high:
            return 0
        case .mid:
            return maxHeight - midHeight
        case .low:
            return maxHeight - minHeight
        }
    }
    
    private var indicator: some View {
        RoundedRectangle(cornerRadius: Constants.radius)
            .fill(Color.secondary)
            .frame(width: Constants.indicatorWidth, height: Constants.indicatorHeight)
    }
    
    init(maxHeight: CGFloat, @ViewBuilder content: () -> Content) {
        self.minHeight = maxHeight * Constants.minHeightRatio
        self.midHeight = maxHeight * Constants.midHeightRatio
        self.maxHeight = maxHeight
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                self.indicator.padding()
                self.content
            }
            .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(Constants.radius)
            .frame(height: geometry.size.height, alignment: .bottom)
            .offset(y: max(self.offset + self.translation, 0))
            .animation(.spring())
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                }.onEnded { value in
                    // Define drag direction
                    let draggedDown = value.translation.height > 0
                    
                    // Define drag lengthes
                    let snapDistanceLong = self.maxHeight * Constants.snapRatioMax // a long drag
                    let snapDistanceShort = self.maxHeight * Constants.snapRatioMid // a short drag
                    
                    // If the drag is too short we don't change anything
                    if abs(value.translation.height) < snapDistanceShort {
                        return
                    }
                    
                    // If we're in the mid position, we don't care abount long or short drags
                    if position == .mid {
                        position = draggedDown ? .low : .high
                        return
                    }
                    
                    // Dragging down from high position
                    if position == .high {
                        if draggedDown {
                            if abs(value.translation.height) > snapDistanceLong {
                                position = .low
                            } else {
                                position = .mid
                            }
                            return
                        } else {
                            // We cannot further drag up from the high position
                            return
                        }
                    }
                    
                    // There's no position left than low - so we only care for dragging up
                    if !draggedDown {
                        if abs(value.translation.height) > snapDistanceLong {
                            position = .high
                        } else {
                            position = .mid
                        }
                        return
                    }
                }
            )
        }
    }
}
