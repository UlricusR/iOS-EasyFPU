//
//  HealthExportPreview.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 10.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct HealthExportPreview: View {
    @ObservedObject var carbsRegime: CarbsRegime
    var timeKeys: [Date] {
        Array(carbsRegime.entries.keys).sorted()
    }
    var carbsRegimeEntries: [Date: [CarbsEntry]] {
        carbsRegime.entries
    }
    
    var body: some View {
        VStack {
            GeometryReader { reader in
                ZStack {
                    // The diagram
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(timeKeys, id: \.self) { time in
                                ChartBar(time: time, entries: carbsRegimeEntries[time], maxCarbs: carbsRegime.maxTotalCarbs)
                            }
                        }
                        .padding()
                        .animation(.interactiveSpring())
                    }
                    
                    // The fading right side of the view
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
            
            // The legend
            HStack {
                Rectangle()
                    .fill(MealSugarsView.color)
                    .frame(width: 15, height: 15)
                Text("Sugars")
                
                Rectangle()
                    .fill(MealCarbsView.color)
                    .frame(width: 15, height: 15)
                Text("Regular Carbs")
                
                Rectangle()
                    .fill(MealECarbsView.color)
                    .frame(width: 15, height: 15)
                Text("e-Carbs")
            }.font(.caption)
        }
    }
}

struct ChartBar: View {
    var time: Date
    var entries: [CarbsEntry]? // This should never be nil, if so, we need to do something... see below
    var maxCarbs: Double
    private let maxBarHeight: Double = 120
    private var multiplier: Double {
        maxBarHeight / maxCarbs
    }
    
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
                        if entries!.count == 1 { // The simplest case - one single carbs entry
                            // The amount as text
                            Text(formatValue(value: entries![0].value))
                                .font(.footnote)
                                .rotationEffect(.degrees(-90))
                                .offset(y: multiplier * entries![0].value <= 40 ? 0 : 40)
                                .zIndex(1)
                            
                            // The entry
                            Rectangle()
                                .fill(getBarColor(carbsEntryType: entries![0].type))
                                .frame(width: 15, height: CGFloat(multiplier * entries![0].value))
                            
                        } else { // Multiple entries, so we need to stack them
                            stackedBar(entries: entries!)
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
    
    private func getBarColor(carbsEntryType: CarbsEntryType) -> Color {
        switch carbsEntryType {
        case .sugars:
            return MealSugarsView.color
        case .carbs:
            return MealCarbsView.color
        case .eCarbs:
            return MealECarbsView.color
        }
    }
    
    @ViewBuilder
    private func stackedBar(entries: [CarbsEntry]) -> some View {
        let totalCarbs = getTotalCarbs(entries: entries)
        
        // The amount as text
        Text(formatValue(value: totalCarbs))
            .font(.footnote)
            .rotationEffect(.degrees(-90))
            .zIndex(1)
        
        // The entry
        ForEach(entries, id: \.self) { entry in
            Rectangle()
                .fill(getBarColor(carbsEntryType: entry.type))
                .frame(width: 15, height: CGFloat(multiplier * entry.value))
        }
    }
    
    private func getTotalCarbs(entries: [CarbsEntry]) -> Double {
        var totalCarbs = 0.0
        for entry in entries {
            totalCarbs += entry.value
        }
        return totalCarbs
    }
}
