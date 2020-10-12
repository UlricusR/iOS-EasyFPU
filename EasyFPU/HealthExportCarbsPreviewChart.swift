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
    var xAxisLabels: [String] {
        var xAxisLabels = [String]()
        for timeKey in timeKeys {
            xAxisLabels.append(HealthExportCarbsPreviewChart.timeStyle.string(from: timeKey))
        }
        return xAxisLabels
    }
    var xScale: CGFloat {
        /*let scalingFactor = 0.05
        let maxXScale = 1.5
        let xScale = Double(timeKeys.count) * scalingFactor
        return CGFloat(min(xScale, maxXScale))*/
        return 1.2
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
        
        // Fit scale
        chart.zoom(scaleX: xScale, scaleY: 1, x: 1, y: 1)
        
        // Format axis
        chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisLabels)
        let yAxisFormatter = YAxisFormatter()
        chart.leftAxis.valueFormatter = yAxisFormatter
        chart.rightAxis.valueFormatter = yAxisFormatter
        
        // Animate
        chart.animate(xAxisDuration: 0.5)
        chart.animate(yAxisDuration: 0.5)
        
        // Add initial data
        chart.data = addData()
        return chart
    }
    
    func updateUIView(_ uiView: BarChartView, context: Context) {
        uiView.barData?.clearValues()
        uiView.data = addData()
        uiView.zoom(scaleX: xScale, scaleY: 1, x: 1, y: 1)
        uiView.data?.notifyDataChanged()
        uiView.notifyDataSetChanged()
    }
    
    private func addData() -> BarChartData {
        // Prepare data entries
        var dataEntries = [BarChartDataEntry]()
        for index in 0..<timeKeys.count {
            let dataEntry = prepareData(index: index)
            if dataEntry.positiveSum > 0 {
                dataEntries.append(dataEntry)
            }
        }
        
        // Create data set
        let dataSet = BarChartDataSet(entries: dataEntries, label: NSLocalizedString("Carbs in g", comment: ""))
        
        // Style data set
        dataSet.colors = [MealSugarsView.color, MealCarbsView.color, MealECarbsView.color]
        dataSet.stackLabels = [
            NSLocalizedString("Sugars", comment: ""),
            NSLocalizedString("Regular Carbs", comment: ""),
            NSLocalizedString("e-Carbs", comment: "")
        ]
        
        
        // Return data set
        return BarChartData(dataSet: dataSet)
    }
    
    private func prepareData(index: Int) -> BarChartDataEntry {
        guard let entries = carbsRegimeEntries[timeKeys[index]] else { // Should never happen
            fatalError("Fatal error: Carbs entries are nil!")
        }
        if entries.count != 3 { // Should never happen
            fatalError("Fatal error: There should always be 3 entries!")
        } else {
            return BarChartDataEntry(x: Double(index), yValues: [entries[0].value, entries[1].value, entries[2].value])
        }
    }
    
    private func createEntry(type: CarbsEntryType, time: Date, value: Double) {
        let entry = BarChartDataEntry(x: time.timeIntervalSince(self.carbsRegime.globalStartTime), y: value)
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

class YAxisFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        DataHelper.doubleFormatter(numberOfDigits: value >= 100 ? 0 : (value >= 10 ? 1 : 2)).string(from: NSNumber(value: value))!
    }
}
