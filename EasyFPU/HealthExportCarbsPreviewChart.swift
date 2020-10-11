//
//  HealthExportCarbsPreviewChart.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 11.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import Charts

struct HealthExportCarbsPreviewChart: UIViewRepresentable {
    @ObservedObject var carbsRegime: CarbsRegime
    var sugarsDataSet: BarChartDataSet
    var carbsDataSet: BarChartDataSet
    var eCarbsDataSet: BarChartDataSet
    var timeKeys: [Date] {
        Array(carbsRegime.entries.keys).sorted()
    }
    var carbsRegimeEntries: [Date: [CarbsEntry]] {
        carbsRegime.entries
    }
    
    static var timeStyle: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    init(carbsRegime: CarbsRegime) {
        self.carbsRegime = carbsRegime
        
        self.sugarsDataSet = BarChartDataSet()
        self.sugarsDataSet.setColor(MealSugarsView.color)
        self.sugarsDataSet.label = NSLocalizedString("Sugars", comment: "")
        
        self.carbsDataSet = BarChartDataSet()
        self.carbsDataSet.setColor(MealCarbsView.color)
        self.carbsDataSet.label = NSLocalizedString("Regular Carbs", comment: "")
        
        self.eCarbsDataSet = BarChartDataSet()
        self.eCarbsDataSet.setColor(MealECarbsView.color)
        self.eCarbsDataSet.label = NSLocalizedString("e-Carbs", comment: "")
    }
    
    func makeUIView(context: Context) -> BarChartView {
        let chart = BarChartView()
        chart.data = addData()
        return chart
    }
    
    func updateUIView(_ uiView: BarChartView, context: Context) {
        
    }
    
    private func addData() -> BarChartData {
        let data = BarChartData()
        
        for timeKey in timeKeys {
            createBar(time: timeKey, entries: carbsRegimeEntries[timeKey])
        }
        
        data.addDataSet(sugarsDataSet)
        data.addDataSet(carbsDataSet)
        data.addDataSet(eCarbsDataSet)
        return data
    }
    
    private func createBar(time: Date, entries: [CarbsEntry]?) {
        if entries == nil { // Should never happen, but if so, we just do nothing
            debugPrint("Fatal error: Carbs entries are nil!")
        } else {
            for entry in entries! {
                createEntry(type: entry.type, time: time, value: entry.value)
            }
        }
    }
    
    private func formatValue(value: Double) -> String {
        DataHelper.doubleFormatter(numberOfDigits: value >= 100 ? 0 : (value >= 10 ? 1 : 2)).string(from: NSNumber(value: value))!
    }
    
    private func createEntry(type: CarbsEntryType, time: Date, value: Double) {
        let entry = BarChartDataEntry(x: time.timeIntervalSinceReferenceDate, y: value)
        switch type {
        case .sugars:
            sugarsDataSet.append(entry)
        case .carbs:
            carbsDataSet.append(entry)
        case .eCarbs:
            eCarbsDataSet.append(entry)
        }
    }
    
    typealias UIViewType = BarChartView
}
