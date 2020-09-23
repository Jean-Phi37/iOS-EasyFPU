//
//  SettingsHelper.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 09.09.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

class UserSettings: ObservableObject {
    // MARK: - The keys
    enum UserDefaultsType {
        case bool(Bool, UserSettings.UserDefaultsBoolKey)
        case double(Double, UserSettings.UserDefaultsDoubleKey)
        case int(Int, UserSettings.UserDefaultsIntKey)
    }
    
    enum UserDefaultsBoolKey: String, CaseIterable {
        case disclaimerAccepted = "DisclaimerAccepted"
        case exportECarbs = "ExportECarbs"
        case exportTotalMealCarbs = "ExportTotalMealCarbs"
        case exportTotalMealSugars = "ExportTotalMealSugars"
        case exportTotalMealCalories = "ExportTotalMealCalories"
    }
    
    enum UserDefaultsDoubleKey: String, CaseIterable {
        case absorptionTimeCarbsDuration = "AbsorptionTimeCarbsDuration"
        case eCarbsFactor = "ECarbsFactor"
    }
    
    enum UserDefaultsIntKey: String, CaseIterable {
        case absorptionTimeCarbsDelay = "AbsorptionTimeCarbsDelay"
        case absorptionTimeCarbsInterval = "AbsorptionTimeCarbsInterval"
        case absorptionTimeECarbsDelay = "AbsorptionTimeECarbsDelay"
        case absorptionTimeECarbsInterval = "AbsorptionTimeECarbsInterval"
    }
    
    // MARK: - The key store for syncing via iCloud
    private static var keyStore = NSUbiquitousKeyValueStore()
    
    // MARK: - Dynamic user settings are treated here
    
    @Published var absorptionTimeCarbsDelayInMinutes: Int
    @Published var absorptionTimeCarbsIntervalInMinutes: Int
    @Published var absorptionTimeCarbsDurationInHours: Double
    @Published var absorptionTimeECarbsDelayInMinutes: Int
    @Published var absorptionTimeECarbsIntervalInMinutes: Int
    @Published var eCarbsFactor: Double
    
    static let shared = UserSettings(
        absorptionTimeECarbsDelayInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.absorptionTimeECarbsDelay) ?? AbsorptionSchemeViewModel.absorptionTimeECarbsDelayDefault,
        absorptionTimeECarbsIntervalInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.absorptionTimeECarbsInterval) ?? AbsorptionSchemeViewModel.absorptionTimeECarbsIntervalDefault,
        absorptionTimeCarbsDelayInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.absorptionTimeCarbsDelay) ?? AbsorptionSchemeViewModel.absorptionTimeCarbsDelayDefault,
        absorptionTimeCarbsIntervalInMinutes: UserSettings.getValue(for: UserDefaultsIntKey.absorptionTimeCarbsInterval) ?? AbsorptionSchemeViewModel.absorptionTimeCarbsIntervalDefault,
        absorptionTimeCarbsDurationInHours: UserSettings.getValue(for: UserDefaultsDoubleKey.absorptionTimeCarbsDuration) ?? AbsorptionSchemeViewModel.absoprtionTimeCarbsDurationDefault,
        eCarbsFactor: UserSettings.getValue(for: UserDefaultsDoubleKey.eCarbsFactor) ?? AbsorptionSchemeViewModel.eCarbsFactorDefault
    )
    
    private init(
        absorptionTimeECarbsDelayInMinutes: Int,
        absorptionTimeECarbsIntervalInMinutes: Int,
        absorptionTimeCarbsDelayInMinutes: Int,
        absorptionTimeCarbsIntervalInMinutes: Int,
        absorptionTimeCarbsDurationInHours: Double,
        eCarbsFactor: Double
    ) {
        self.absorptionTimeCarbsDelayInMinutes = absorptionTimeCarbsDelayInMinutes // in minutes
        self.absorptionTimeCarbsIntervalInMinutes = absorptionTimeCarbsIntervalInMinutes // in minutes
        self.absorptionTimeCarbsDurationInHours = absorptionTimeCarbsDurationInHours // in hours
        self.absorptionTimeECarbsDelayInMinutes = absorptionTimeECarbsDelayInMinutes // in minutes
        self.absorptionTimeECarbsIntervalInMinutes = absorptionTimeECarbsIntervalInMinutes // in minutes
        self.eCarbsFactor = eCarbsFactor
    }
    
    // MARK: - Static helper functions
    
    static func set(_ parameter: UserDefaultsType, errorMessage: inout String) -> Bool {
        switch parameter {
        case .bool(let value, let key):
            if !UserDefaultsBoolKey.allCases.contains(key) {
                errorMessage = NSLocalizedString("Fatal error, please inform app developer: Cannot store parameter: ", comment: "") + key.rawValue
                return false
            }
            UserSettings.keyStore.set(value, forKey: key.rawValue)
        case .double(let value, let key):
            if !UserDefaultsDoubleKey.allCases.contains(key) {
                errorMessage = NSLocalizedString("Fatal error, please inform app developer: Cannot store parameter: ", comment: "") + key.rawValue
                return false
            }
            UserSettings.keyStore.set(value, forKey: key.rawValue)
        case .int(let value, let key):
            if !UserDefaultsIntKey.allCases.contains(key) {
                errorMessage = NSLocalizedString("Fatal error, please inform app developer: Cannot store parameter: ", comment: "") + key.rawValue
                return false
            }
            UserSettings.keyStore.set(value, forKey: key.rawValue)
        }
        
        // Synchronize
        UserSettings.keyStore.synchronize()
        return true
    }
    
    static func getValue(for key: UserDefaultsBoolKey) -> Bool? {
        UserSettings.keyStore.object(forKey: key.rawValue) == nil ? nil : UserSettings.keyStore.bool(forKey: key.rawValue)
    }
    
    static func getValue(for key: UserDefaultsDoubleKey) -> Double? {
        UserSettings.keyStore.object(forKey: key.rawValue) == nil ? nil : UserSettings.keyStore.double(forKey: key.rawValue)
    }
    
    static func getValue(for key: UserDefaultsIntKey) -> Int? {
        UserSettings.keyStore.object(forKey: key.rawValue) == nil ? nil : Int(UserSettings.keyStore.longLong(forKey: key.rawValue))
    }
}
