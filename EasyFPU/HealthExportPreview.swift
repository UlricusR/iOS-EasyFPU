//
//  HealthExportPreview.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 10.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct HealthExportPreview: View {
    @ObservedObject var carbsRegimeCalculator: CarbsRegimeCalculator
    @ObservedObject var carbsRegime: CarbsRegime
    var timeKeys: [Date] {
        Array(carbsRegime.entries.keys).sorted()
    }
    var carbsRegimeEntries: [Date: [CarbsEntry]] {
        carbsRegime.entries
    }
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(timeKeys, id: \.self) { time in
                            ChartBar(time: time, entries: carbsRegimeEntries[time], carbsRegimeCalculator: carbsRegimeCalculator)
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
            // Fit chart bars
            self.carbsRegimeCalculator.fitCarbChartBars()
        }
    }
}

struct ChartBar: View {
    var time: Date
    var entries: [CarbsEntry]? // This should never be nil, if so, we need to do something... see below
    var carbsRegimeCalculator: CarbsRegimeCalculator
    
    static var timeStyle: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        if entries == nil { // Should never happen, but if so, we just return an empty view
            debugPrint("Fatal error: Carbs entries are nil!")
            return AnyView( EmptyView() )
        } else {
            return AnyView(
                VStack {
                    // The Spacer to move all segments down towards the x axis
                    Spacer()
                    
                    // The different cases for the chart bar segments
                    if !entries!.isEmpty {
                            if entries!.count == 1 { // The simplest and probably preveiling case - one single carbs entry
                                // The amount as text
                                Text(formatValue(value: entries![0].value))
                                    .font(.footnote)
                                    .rotationEffect(.degrees(-90))
                                    .offset(y: self.carbsRegimeCalculator.appliedMultiplier * entries![0].value <= 40 ? 0 : 40)
                                    .zIndex(1)
                            
                                if entries![0].value <= self.carbsRegimeCalculator.maxCarbsWithoutSplitting {
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(width: 15, height: CGFloat(self.carbsRegimeCalculator.appliedMultiplier * entries![0].value))
                            } else {
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(width: 15, height: CGFloat(self.carbsRegimeCalculator.getSplitBarHeight(carbs: entries![0].value)))
                                    .overlay(Rectangle()
                                        .fill(Color(UIColor.systemBackground))
                                        .frame(width: 20, height: 5)
                                        .padding([.bottom, .top], 1.0)
                                        .background(Color.primary)
                                        .rotationEffect(.degrees(-10))
                                        .offset(y: CGFloat(self.carbsRegimeCalculator.getSplitBarHeight(carbs: entries![0].value) / 2 - 10))
                                )
                            }
                        }
                    }
                    
                    // The time axis segment
                    Rectangle()
                        .fill(Color(UIColor.systemBackground))
                        .frame(width: 40, height: 0)
                        .padding([.top], 2.0)
                        .background(Color.primary)
                    
                    // The time
                    Text(ChartBar.timeStyle.string(from: time))
                        .fixedSize()
                        .layoutPriority(1)
                        .font(.footnote)
                        .rotationEffect(.degrees(-90))
                        .offset(y: 10)
                        .frame(height: 50)
                        .lineLimit(1)
                }.frame(width: 30)
            )
        }
    }
    
    private func formatValue(value: Double) -> String {
        DataHelper.doubleFormatter(numberOfDigits: value >= 100 ? 0 : (value >= 10 ? 1 : 2)).string(from: NSNumber(value: value))!
    }
}
