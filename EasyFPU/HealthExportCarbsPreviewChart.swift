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
    let minXRange: Double = 10
    var initialXAxisRange: Double {
        let range = carbsRegime.timeOfFirstEntry.timeIntervalSince(carbsRegime.globalStartTime) / 60 / Double(carbsRegime.intervalInMinutes) + 2.0
        return max(minXRange, range)
    }
    
    static var timeStyle: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    init(carbsRegime: CarbsRegime) {
        self.carbsRegime = carbsRegime
        
        self.sugarsDataSet = BarChartDataSet()
        self.sugarsDataSet.setColor(ComposedFoodItemSugarsView.color)
        self.sugarsDataSet.label = NSLocalizedString("Sugars", comment: "")
        
        self.carbsDataSet = BarChartDataSet()
        self.carbsDataSet.setColor(ComposedFoodItemCarbsView.color)
        self.carbsDataSet.label = NSLocalizedString("Regular Carbs", comment: "")
        
        self.eCarbsDataSet = BarChartDataSet()
        self.eCarbsDataSet.setColor(ComposedFoodItemECarbsView.color)
        self.eCarbsDataSet.label = NSLocalizedString("e-Carbs", comment: "")
    }
    
    func makeUIView(context: Context) -> BarChartView {
        let chart = BarChartView()
        
        // Format axis
        chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisLabels)
        let yAxisFormatter = YAxisFormatter()
        chart.leftAxis.valueFormatter = yAxisFormatter
        chart.rightAxis.valueFormatter = yAxisFormatter
        
        // We only want scaling in x, not in y
        chart.scaleXEnabled = true
        chart.scaleYEnabled = false
        
        // Text if no data
        chart.noDataText = NSLocalizedString("No data selected", comment: "")
        
        // Draw values inside bars
        chart.drawValueAboveBarEnabled = false
        
        // Add initial data
        chart.data = addData()
        
        // Modify the view - this needs to be done _after_ having set the data!!!
        chart.setVisibleXRange(minXRange: minXRange, maxXRange: Double(timeKeys.count))
        
        // Set the initial axis range to show at least the first non-zero entry + two further ones, but not less than 10
        chart.xAxis.axisRange = initialXAxisRange
        
        // The chart is done - return it
        return chart
    }
    
    func updateUIView(_ uiView: BarChartView, context: Context) {
        // Clear all values and add new ones
        uiView.barData?.clearValues()
        uiView.data = addData()
        
        // Re-format x axis
        uiView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xAxisLabels)
        
        // Modify the view - this needs to be done _after_ having set the data!!!
        uiView.setVisibleXRange(minXRange: minXRange, maxXRange: Double(timeKeys.count))
        
        // Set the initial axis range to show at least the first non-zero entry + two further ones, but not less than 10
        uiView.xAxis.axisRange = initialXAxisRange
        
        // Notify change
        uiView.notifyDataSetChanged()
    }
    
    private func addData() -> BarChartData {
        // Prepare data entries
        var dataEntries = [BarChartDataEntry]()
        for index in 0..<timeKeys.count {
            let dataEntry = prepareData(index: index)
            dataEntries.append(dataEntry)
        }
        
        // Create data set
        let dataSet = BarChartDataSet(entries: dataEntries, label: NSLocalizedString("Carbs in g", comment: ""))
        
        // Style data set
        dataSet.colors = [ComposedFoodItemSugarsView.color, ComposedFoodItemCarbsView.color, ComposedFoodItemECarbsView.color]
        dataSet.stackLabels = [
            NSLocalizedString("Sugars_short", comment: ""),
            NSLocalizedString("Carbs_short", comment: ""),
            NSLocalizedString("eCarbs_short", comment: "")
        ]
        
        // Format data
        dataSet.valueFormatter = BarValueFormatter()
        
        // Return data
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

class BarValueFormatter: IValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        value == 0.0 ? "" : DataHelper.doubleFormatter(numberOfDigits: value >= 100 ? 0 : (value >= 10 ? 1 : 2)).string(from: NSNumber(value: value))!
    }
}
