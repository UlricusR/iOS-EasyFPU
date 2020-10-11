//
//  Bar.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 11.10.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI
import Charts

struct Bar: UIViewRepresentable {
    var entries: [BarChartDataEntry]
    
    func makeUIView(context: Context) -> BarChartView {
        let chart = BarChartView()
        chart.data = addData()
        return chart
    }
    
    func updateUIView(_ uiView: BarChartView, context: Context) {
        
    }
    
    func addData() -> BarChartData {
        let data = BarChartData()
        let dataSet = BarChartDataSet(entries: entries)
        data.addDataSet(dataSet)
        return data
    }
    
    typealias UIViewType = BarChartView
}

struct Bar_Previews: PreviewProvider {
    static var previews: some View {
        
        Bar(entries: [
            BarChartDataEntry(x: 1, yValues: [1.0, 2.0]),
            BarChartDataEntry(x: 2, y: 2),
            BarChartDataEntry(x: 3, y: 1),
            BarChartDataEntry(x: 5, y: 1),
            BarChartDataEntry(x: 7, y: 4)
        ])
    }
}
