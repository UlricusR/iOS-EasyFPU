//
//  BannerView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 07/12/2024.
//  Copyright © 2024 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct BannerView: View {
    @EnvironmentObject private var bannerService: BannerService
    @State private var showAllText: Bool = false
    let banner: BannerType
    
    var body: some View {
        VStack {
            Group {
                bannerContent()
            }
        }
        .onAppear {
            guard !banner.isPersistent else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    bannerService.isAnimating = false
                    bannerService.bannerType = nil
                }
            }
        }
        .offset(y: bannerService.dragOffset.height)
        .opacity(bannerService.isAnimating ? max(0, (1.0 - Double(bannerService.dragOffset.height) / bannerService.maxDragOffsetHeight)) : 0)
        .gesture(
            DragGesture()
                .onChanged{ gesture in
                    if gesture.translation.height < 0 {
                        bannerService.dragOffset = gesture.translation
                    }
                }
                .onEnded { value in
                    if bannerService.dragOffset.height < -20 {
                        withAnimation{
                            bannerService.removeBanner()
                        }
                    } else {
                        bannerService.dragOffset = .zero
                    }
                }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal)
    }
    
    private func bannerContent() -> some View {
        HStack(spacing: 10) {
            Image(systemName: banner.imageName)
                .padding(5)
                .background(banner.backgroundColor)
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.2), radius: 3.0, x: -3, y:4)
            VStack(spacing: 5) {
                Text(banner.message)
                    .foregroundColor(.black)
                    .fontWeight(.light)
                    .font(banner.message.count > 25 ? .caption : .footnote)
                    .multilineTextAlignment(.leading)
                    .lineLimit(showAllText ? nil : 2)
                (banner.message.count > 100 && banner.isPersistent) ?
                Image(systemName: self.showAllText ? "chevron.compact.up" : "chevron.compact.down")
                    .foregroundColor(Color.white.opacity(0.6))
                    .fontWeight(.light)
                : nil
            }
            banner.isPersistent ?
            Button {
                withAnimation{
                    bannerService.removeBanner()
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
            .shadow(color: .black.opacity(0.2), radius: 3.0, x: 3, y:4)
            : nil
        }
        .foregroundColor(.white)
        .padding(8)
        .padding(.trailing, 2)
        .background(banner.backgroundColor)
        .cornerRadius(10)
        .shadow(radius: 3.0, x: -2, y:2)
        .onTapGesture {
            withAnimation {
                self.showAllText.toggle()
            }
        }
    }
}
