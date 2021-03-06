//
//  FoodItemViewModel.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 24.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import Foundation

enum FoodItemViewModelError {
    case name(String), calories(String), carbs(String), sugars(String), amount(String), tooMuchCarbs(String), tooMuchSugars(String)
}

class FoodItemViewModel: ObservableObject, Codable, Hashable {
    private var id = UUID()
    @Published var name: String
    @Published var favorite: Bool
    @Published var caloriesPer100gAsString: String = "" {
        willSet {
            let result = DataHelper.checkForPositiveDouble(valueAsString: newValue, allowZero: true)
            switch result {
            case .success(let caloriesAsDouble):
                caloriesPer100g = caloriesAsDouble
            case .failure(let err):
                debugPrint(DataHelper.getErrorMessage(from: err))
                return
            }
        }
    }
    @Published var carbsPer100gAsString: String = "" {
        willSet {
            let result = DataHelper.checkForPositiveDouble(valueAsString: newValue, allowZero: true)
            switch result {
            case .success(let carbsAsDouble):
                carbsPer100g = carbsAsDouble
            case .failure(let err):
                debugPrint(DataHelper.getErrorMessage(from: err))
                return
            }
        }
    }
    @Published var sugarsPer100gAsString: String = "" {
        willSet {
            let result = DataHelper.checkForPositiveDouble(valueAsString: newValue, allowZero: true)
            switch result {
            case .success(let sugarsAsDouble):
                sugarsPer100g = sugarsAsDouble
            case .failure(let err):
                debugPrint(DataHelper.getErrorMessage(from: err))
                return
            }
        }
    }
    @Published var amountAsString: String = "" {
        willSet {
            let result = DataHelper.checkForPositiveInt(valueAsString: newValue, allowZero: true)
            switch result {
            case .success(let amountAsInt):
                amount = amountAsInt
            case .failure(let err):
                debugPrint(DataHelper.getErrorMessage(from: err))
                return
            }
        }
    }
    private(set) var caloriesPer100g: Double = 0.0
    private(set) var carbsPer100g: Double = 0.0
    private(set) var sugarsPer100g: Double = 0.0
    private(set) var amount: Int = 0
    var typicalAmounts = [TypicalAmountViewModel]()
    var cdFoodItem: FoodItem?
    
    enum CodingKeys: String, CodingKey {
        case foodItem
        case amount, caloriesPer100g, carbsPer100g, sugarsPer100g, favorite, name, typicalAmounts
    }
    
    init(name: String, favorite: Bool, caloriesPer100g: Double, carbsPer100g: Double, sugarsPer100g: Double, amount: Int) {
        self.name = name
        self.favorite = favorite
        self.caloriesPer100g = caloriesPer100g
        self.carbsPer100g = carbsPer100g
        self.sugarsPer100g = sugarsPer100g
        self.amount = amount
        
        self.caloriesPer100gAsString = caloriesPer100g == 0 ? "" : DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: caloriesPer100g))!
        self.carbsPer100gAsString = carbsPer100g == 0 ? "" : DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: carbsPer100g))!
        self.sugarsPer100gAsString = sugarsPer100g == 0 ? "" : DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: sugarsPer100g))!
        self.amountAsString = amount == 0 ? "" : NumberFormatter().string(from: NSNumber(value: amount))!
    }
    
    init(from cdFoodItem: FoodItem) {
        self.name = cdFoodItem.name ?? NSLocalizedString("- Unnamned -", comment: "")
        self.favorite = cdFoodItem.favorite
        self.caloriesPer100g = cdFoodItem.caloriesPer100g
        self.carbsPer100g = cdFoodItem.carbsPer100g
        self.sugarsPer100g = cdFoodItem.sugarsPer100g
        self.amount = Int(cdFoodItem.amount)
        self.cdFoodItem = cdFoodItem
        
        self.caloriesPer100gAsString = cdFoodItem.caloriesPer100g == 0 ? "" : DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: cdFoodItem.caloriesPer100g))!
        self.carbsPer100gAsString = cdFoodItem.carbsPer100g == 0 ? "" : DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: cdFoodItem.carbsPer100g))!
        self.sugarsPer100gAsString = cdFoodItem.sugarsPer100g == 0 ? "" : DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: cdFoodItem.sugarsPer100g))!
        self.amountAsString = cdFoodItem.amount == 0 ? "" : NumberFormatter().string(from: NSNumber(value: cdFoodItem.amount))!
        
        if cdFoodItem.typicalAmounts != nil {
            for typicalAmount in cdFoodItem.typicalAmounts!.allObjects {
                let castedTypicalAmount = typicalAmount as! TypicalAmount
                typicalAmounts.append(TypicalAmountViewModel(from: castedTypicalAmount))
            }
        }
    }
    
    init?(name: String, favorite: Bool, caloriesAsString: String, carbsAsString: String, sugarsAsString: String, amountAsString: String, error: inout FoodItemViewModelError) {
        // Check for a correct name
        let foodName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if foodName == "" {
            error = .name(NSLocalizedString("Name must not be empty", comment: ""))
            return nil
        } else {
            self.name = foodName
        }
        
        // Set favorite
        self.favorite = favorite
        
        // Check for valid calories
        let caloriesResult = DataHelper.checkForPositiveDouble(valueAsString: caloriesAsString == "" ? "0" : caloriesAsString, allowZero: true)
        switch caloriesResult {
        case .success(let caloriesAsDouble):
            caloriesPer100g = caloriesAsDouble
        case .failure(let err):
            let errorMessage = DataHelper.getErrorMessage(from: err)
            error = .calories(errorMessage)
            return nil
        }
        self.caloriesPer100gAsString = caloriesAsString
        
        // Check for valid carbs
        let carbsResult = DataHelper.checkForPositiveDouble(valueAsString: carbsAsString == "" ? "0" : carbsAsString, allowZero: true)
        switch carbsResult {
        case .success(let carbsAsDouble):
            carbsPer100g = carbsAsDouble
        case .failure(let err):
            let errorMessage = DataHelper.getErrorMessage(from: err)
            error = .carbs(errorMessage)
            return nil
        }
        self.carbsPer100gAsString = carbsAsString
        
        // Check for valid sugars
        let sugarsResult = DataHelper.checkForPositiveDouble(valueAsString: sugarsAsString == "" ? "0" : sugarsAsString, allowZero: true)
        switch sugarsResult {
        case .success(let sugarsAsDouble):
            sugarsPer100g = sugarsAsDouble
        case .failure(let err):
            let errorMessage = DataHelper.getErrorMessage(from: err)
            error = .sugars(errorMessage)
            return nil
        }
        self.sugarsPer100gAsString = sugarsAsString
        
        // Check if sugars exceed carbs
        if sugarsPer100g > carbsPer100g {
            error = .tooMuchSugars(NSLocalizedString("Sugars exceed carbs", comment: ""))
            return nil
        }
        
        // Check if calories from carbs exceed total calories
        if carbsPer100g * 4 > caloriesPer100g {
            error = .tooMuchCarbs(NSLocalizedString("Calories from carbs (4 kcal per gram) exceed total calories", comment: ""))
            return nil
        }
        
        // Check for valid amount
        let amountResult = DataHelper.checkForPositiveInt(valueAsString: amountAsString == "" ? "0" : amountAsString, allowZero: true)
        switch amountResult {
        case .success(let amountAsInt):
            amount = amountAsInt
        case .failure(let err):
            let errorMessage = DataHelper.getErrorMessage(from: err)
            error = .amount(errorMessage)
            return nil
        }
        self.amountAsString = amountAsString
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let foodItem = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .foodItem)
        amount = try foodItem.decode(Int.self, forKey: .amount)
        caloriesPer100g = try foodItem.decode(Double.self, forKey: .caloriesPer100g)
        carbsPer100g = try foodItem.decode(Double.self, forKey: .carbsPer100g)
        sugarsPer100g = try foodItem.decode(Double.self, forKey: .sugarsPer100g)
        favorite = try foodItem.decode(Bool.self, forKey: .favorite)
        name = try foodItem.decode(String.self, forKey: .name)
        typicalAmounts = try foodItem.decode([TypicalAmountViewModel].self, forKey: .typicalAmounts)
        
        guard
            let caloriesAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: caloriesPer100g)),
            let carbsAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: carbsPer100g)),
            let sugarsAsString = DataHelper.doubleFormatter(numberOfDigits: 5).string(from: NSNumber(value: sugarsPer100g)),
            let amountAsString = NumberFormatter().string(from: NSNumber(value: amount))
        else {
            throw InvalidNumberError.inputError(NSLocalizedString("Fatal error: Cannot convert numbers into string, please contact app developer", comment: ""))
        }
        self.caloriesPer100gAsString = caloriesAsString
        self.carbsPer100gAsString = carbsAsString
        self.sugarsPer100gAsString = sugarsAsString
        self.amountAsString = amountAsString
    }
    
    func getCalories() -> Double {
        Double(self.amount) / 100 * self.caloriesPer100g
    }
    
    func getCarbsInclSugars() -> Double {
        Double(self.amount) / 100 * self.carbsPer100g
    }
    
    func getSugarsOnly() -> Double {
        Double(self.amount) / 100 * self.sugarsPer100g
    }
    
    func getRegularCarbs(when treatSugarsSeparately: Bool) -> Double {
        Double(self.amount) / 100 * (treatSugarsSeparately ? (self.carbsPer100g - self.sugarsPer100g) : self.carbsPer100g)
    }
    
    func getSugars(when treatSugarsSeparately: Bool) -> Double {
        Double(self.amount) / 100 * (treatSugarsSeparately ? self.sugarsPer100g : 0)
    }
    
    func getFPU() -> FPU {
        // 1g carbs has ~4 kcal, so calculate carb portion of calories
        let carbsCal = Double(self.amount) / 100 * self.carbsPer100g * 4;

        // The carbs from fat and protein is the remainder
        let calFromFP = getCalories() - carbsCal;

        // 100kcal makes 1 FPU
        let fpus = calFromFP / 100;

        // Create and return the FPU object
        return FPU(fpu: fpus)
    }
    
    func updateCDFoodItem(_ cdFoodItem: inout FoodItem) {
        cdFoodItem.name = name
        cdFoodItem.amount = Int64(amount)
        cdFoodItem.caloriesPer100g = caloriesPer100g
        cdFoodItem.carbsPer100g = carbsPer100g
        cdFoodItem.sugarsPer100g = sugarsPer100g
        cdFoodItem.favorite = favorite
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var foodItem = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .foodItem)
        try foodItem.encode(amount, forKey: .amount)
        try foodItem.encode(caloriesPer100g, forKey: .caloriesPer100g)
        try foodItem.encode(carbsPer100g, forKey: .carbsPer100g)
        try foodItem.encode(sugarsPer100g, forKey: .sugarsPer100g)
        try foodItem.encode(favorite, forKey: .favorite)
        try foodItem.encode(name, forKey: .name)
        try foodItem.encode(typicalAmounts, forKey: .typicalAmounts)
    }
    
    static func == (lhs: FoodItemViewModel, rhs: FoodItemViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
