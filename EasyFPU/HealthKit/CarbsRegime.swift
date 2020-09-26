//
//  CarbsRegime.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 21.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class CarbsRegime: ObservableObject {
    var globalStartTime: Date
    var globalEndTime: Date
    var intervalInMinutes: Int
    var maxTotalCarbs: Double = 0
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
        let sugarsTimes = sugarsEntries.keys
        let carbsTimes = carbsEntries.keys
        let eCarbsTimes = eCarbsEntries.keys
        
        // Iterate through sugar/carbs/eCarbs entries and put together the total regime
        var time = globalStartTime
        
        repeat {
            var timeSlotHasEntry = false
            
            // Identify (in this order) e-carbs, carbs and sugars for the given time
            let eCarbsIndex = eCarbsTimes.firstIndex(where: { checkTimeInterval(entryTime: $0, actualTime: time, intervalInMinutes: intervalInMinutes) })
            if eCarbsIndex != nil {
                addToCarbsRegime(time: time, entry: eCarbsEntries[eCarbsTimes[eCarbsIndex!]]!)
                timeSlotHasEntry = true
            }
            let carbsIndex = carbsTimes.firstIndex(where: { checkTimeInterval(entryTime: $0, actualTime: time, intervalInMinutes: intervalInMinutes) })
            if carbsIndex != nil {
                addToCarbsRegime(time: time, entry: carbsEntries[carbsTimes[carbsIndex!]]!)
                timeSlotHasEntry = true
            }
            let sugarsIndex = sugarsTimes.firstIndex(where: { checkTimeInterval(entryTime: $0, actualTime: time, intervalInMinutes: intervalInMinutes) })
            if sugarsIndex != nil {
                addToCarbsRegime(time: time, entry: sugarsEntries[sugarsTimes[sugarsIndex!]]!)
                timeSlotHasEntry = true
            }
            if !timeSlotHasEntry {
                // No entry for this timeslot, so make it an empty time slot by adding an empty array
                entries[time] = [CarbsEntry]()
            }
            maxTotalCarbs = max(maxTotalCarbs, getTotalCarbs(time: time))
            
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
    
    private func getTotalCarbs(time: Date) -> Double {
        var totalCarbs = 0.0
        if entries[time] != nil {
            for entry in entries[time]! {
                totalCarbs += entry.value
            }
        }
        return totalCarbs
    }
}