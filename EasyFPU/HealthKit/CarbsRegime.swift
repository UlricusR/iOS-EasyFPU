//
//  CarbsRegime.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 21.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class CarbsRegime: ObservableObject {
    @Published var globalStartTime: Date
    var globalEndTime: Date
    var timeOfFirstEntry: Date
    var intervalInMinutes: Int
    @Published var entries = [Date: [CarbsEntry]]()
    
    static var `default` = CarbsRegime(globalStartTime: Date(), globalEndTime: Date().addingTimeInterval(60*60), intervalInMinutes: 5, sugarsEntries: [Date(): CarbsEntry.default], carbsEntries: [Date(): CarbsEntry.default], eCarbsEntries: [Date(): CarbsEntry.default])
    
    init(
        globalStartTime: Date,
        globalEndTime: Date,
        intervalInMinutes: Int,
        sugarsEntries: [Date: CarbsEntry],
        carbsEntries: [Date: CarbsEntry],
        eCarbsEntries: [Date: CarbsEntry]
    ) {
        self.globalStartTime = globalStartTime
        self.globalEndTime = globalEndTime
        self.intervalInMinutes = intervalInMinutes
        
        // Get all keys (= Dates) from the three carb entry types
        let sugarsTimes = sugarsEntries.keys.sorted()
        let carbsTimes = carbsEntries.keys.sorted()
        let eCarbsTimes = eCarbsEntries.keys.sorted()
        
        // Get first entry time
        timeOfFirstEntry = min(
            sugarsTimes.count > 0 ? sugarsTimes[0] : globalEndTime,
            carbsTimes.count > 0 ? carbsTimes[0] : globalEndTime,
            eCarbsTimes.count > 0 ? eCarbsTimes[0] : globalEndTime
        )
        
        // Iterate through sugar/carbs/eCarbs entries and put together the total regime
        var time = globalStartTime
        
        repeat {
            // Identify (in this order) sugars, carbs and e-carbs for the given time
            let sugarsIndex = sugarsTimes.firstIndex(where: { checkTimeInterval(entryTime: $0, actualTime: time, intervalInMinutes: intervalInMinutes) })
            addToCarbsRegime(time: time, entry: sugarsIndex != nil ? sugarsEntries[sugarsTimes[sugarsIndex!]]! : CarbsEntry(type: .sugars, value: 0.0, date: time))
            
            let carbsIndex = carbsTimes.firstIndex(where: { checkTimeInterval(entryTime: $0, actualTime: time, intervalInMinutes: intervalInMinutes) })
            addToCarbsRegime(time: time, entry: carbsIndex != nil ? carbsEntries[carbsTimes[carbsIndex!]]! : CarbsEntry(type: .carbs, value: 0.0, date: time))
            
            let eCarbsIndex = eCarbsTimes.firstIndex(where: { checkTimeInterval(entryTime: $0, actualTime: time, intervalInMinutes: intervalInMinutes) })
            addToCarbsRegime(time: time, entry: eCarbsIndex != nil ? eCarbsEntries[eCarbsTimes[eCarbsIndex!]]! : CarbsEntry(type: .eCarbs, value: 0.0, date: time))
            
            // Append the time interval
            time = time.addingTimeInterval(TimeInterval(intervalInMinutes * 60))
        } while time <= globalEndTime
    }
    
    private func checkTimeInterval(entryTime: Date, actualTime: Date, intervalInMinutes: Int) -> Bool {
        if entryTime == actualTime { return true }
        if entryTime > actualTime && entryTime < actualTime.addingTimeInterval(TimeInterval(intervalInMinutes * 60)) { return true }
        return false
    }
    
    private func addToCarbsRegime(time: Date, entry: CarbsEntry) {
        if entries[time] == nil {
            entries[time] = [entry]
        } else {
            entries[time]!.append(entry)
        }
    }
}
