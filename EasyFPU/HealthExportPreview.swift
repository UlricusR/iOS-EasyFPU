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
        if self.carbsEntries.requiresTimeSplitting {
            return AnyView(
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(0..<self.carbsEntries.carbsRegime.count, id: \.self) { index in
                            ChartBar(carbsEntries: self.carbsEntries, entry: self.carbsEntries.carbsRegime[index])
                        }
                    }
                    .overlay(Rectangle()
                        .fill(Color(UIColor.systemBackground))
                        .frame(width: 20, height: 5)
                        .padding([.bottom, .top], 1.0)
                        .background(Color.black)
                        .rotationEffect(.degrees(80))
                        .position(x: 70, y: CGFloat(self.carbsEntries.previewHeight + 42))
                    )
                    .padding()
                    .animation(.interactiveSpring())
                }.onAppear() {
                    self.carbsEntries.fitCarbChartBars()
                }
            )
        } else {
            return AnyView(ScrollView(.horizontal) {
                HStack {
                    ForEach(0..<self.carbsEntries.carbsRegime.count, id: \.self) { index in
                        ChartBar(carbsEntries: self.carbsEntries, entry: self.carbsEntries.carbsRegime[index])
                    }
                }
                .padding()
                .animation(.interactiveSpring())
            }.onAppear() {
                self.carbsEntries.fitCarbChartBars()
            })
        }
    }
}

struct ChartBar: View {
    var carbsEntries: CarbsEntries
    var entry: (date: Date, carbs: Double)
    
    static var timeStyle: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 2).string(from: NSNumber(value: entry.carbs))!)
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
            
            Rectangle()
                .fill(Color(UIColor.systemBackground))
                .frame(width: 40, height: 0)
                .padding([.top], 2.0)
                .background(Color.primary)
            
            Text(ChartBar.timeStyle.string(from: entry.date))
                .font(.footnote)
                .rotationEffect(.degrees(-90))
                .offset(y: 10)
                .frame(height: 20)
        }.frame(width: 30)
    }
}
