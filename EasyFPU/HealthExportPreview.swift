//
//  HealthExportPreview.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 10.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct HealthExportPreview: View {
    @ObservedObject var carbsEntries: CarbsEntries
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(0..<self.carbsEntries.carbsRegime.count, id: \.self) { index in
                            ChartBar(carbsEntries: self.carbsEntries, entry: self.carbsEntries.carbsRegime[index], requiresTimeSplitting: index == self.carbsEntries.timeSplittingAfterIndex)
                        }
                    }
                    .padding()
                    .animation(.interactiveSpring())
                }
                
                Rectangle()
                    .fill(
                        LinearGradient(gradient: Gradient(stops: [
                            .init(color: Color(UIColor.systemBackground).opacity(0.01), location: 0),
                            .init(color: Color(UIColor.systemBackground), location: 1)
                        ]), startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: 0.05 * reader.size.width)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }.fixedSize(horizontal: false, vertical: true)
        }
        .onAppear() {
            self.carbsEntries.fitCarbChartBars()
        }
    }
}

struct ChartBar: View {
    var carbsEntries: CarbsEntries
    var entry: (date: Date, carbs: Double)
    var requiresTimeSplitting: Bool
    
    static var timeStyle: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text(DataHelper.doubleFormatter(numberOfDigits: entry.carbs >= 100 ? 0 : (entry.carbs >= 10 ? 1 : 2)).string(from: NSNumber(value: entry.carbs))!)
                .font(.footnote)
                .rotationEffect(.degrees(-90))
                .offset(y: self.carbsEntries.appliedMultiplier * entry.carbs <= 40 ? 0 : 40)
                .zIndex(1)
            
            if entry.carbs <= self.carbsEntries.maxCarbsWithoutSplitting {
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 15, height: CGFloat(self.carbsEntries.appliedMultiplier * entry.carbs))
            } else {
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 15, height: CGFloat(self.carbsEntries.getSplitBarHeight(carbs: entry.carbs)))
                    .overlay(Rectangle()
                        .fill(Color(UIColor.systemBackground))
                        .frame(width: 20, height: 5)
                        .padding([.bottom, .top], 1.0)
                        .background(Color.primary)
                        .rotationEffect(.degrees(-10))
                        .offset(y: CGFloat(self.carbsEntries.getSplitBarHeight(carbs: entry.carbs) / 2 - 10))
                )
            }
            
            if self.requiresTimeSplitting {
                Rectangle()
                    .fill(Color(UIColor.systemBackground))
                    .frame(width: 40, height: 0)
                    .padding([.top], 2.0)
                    .background(Color.primary)
                    .overlay(Rectangle()
                        .fill(Color(UIColor.systemBackground))
                        .frame(width: 20, height: 5)
                        .padding([.bottom, .top], 1.0)
                        .background(Color.black)
                        .rotationEffect(.degrees(80))
                        .offset(x: 20)
                        .zIndex(1)
                    )
            } else {
                Rectangle()
                    .fill(Color(UIColor.systemBackground))
                    .frame(width: 40, height: 0)
                    .padding([.top], 2.0)
                    .background(Color.primary)
            }
            
            Text(ChartBar.timeStyle.string(from: entry.date))
                .fixedSize()
                .layoutPriority(1)
                .font(.footnote)
                .rotationEffect(.degrees(-90))
                .offset(y: 10)
                .frame(height: 50)
                .lineLimit(1)
        }.frame(width: 30)
    }
}
