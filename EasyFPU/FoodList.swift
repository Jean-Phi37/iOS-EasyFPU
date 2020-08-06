//
//  ContentView.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 11.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

struct FoodList: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    var foodItems = FoodItem.fetchAll()
    var absorptionBlocks = AbsorptionBlock.fetchAll()
    var absorptionScheme = AbsorptionScheme()
    @State var showingSheet = false
    @State var activeSheet = ActiveFoodListSheet.addFoodItem
    @State var draftFoodItem = FoodItemViewModel(
        name: "",
        favorite: false,
        caloriesPer100g: 0.0,
        carbsPer100g: 0.0,
        amount: 0
    )
    
    var meal: Meal {
        var meal = Meal(name: "Total meal")
        for foodItem in foodItems {
            meal.add(foodItem: foodItem)
        }
        return meal
    }
    
    var body: some View {
        VStack {
            NavigationView {
                List {
                    Text("Tap to select, long press to edit").font(.caption)
                    ForEach(foodItems, id: \.self) { foodItem in
                        FoodItemView(absorptionScheme: self.absorptionScheme, foodItem: foodItem)
                            .environment(\.managedObjectContext, self.managedObjectContext)
                    }
                    .onDelete(perform: deleteFoodItem)
                }
                .navigationBarTitle("Food List")
                .navigationBarItems(
                    leading: Button(action: {
                        self.activeSheet = .editAbsorptionScheme
                        self.showingSheet = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .imageScale(.large)
                    },
                    trailing: Button(action: {
                        // Add new food item
                        self.draftFoodItem = FoodItemViewModel(
                            name: "",
                            favorite: false,
                            caloriesPer100g: 0.0,
                            carbsPer100g: 0.0,
                            amount: 0
                        )
                        self.activeSheet = .addFoodItem
                        self.showingSheet = true
                    }) {
                        Image(systemName: "plus.circle")
                            .imageScale(.large)
                            .foregroundColor(.green)
                    }
                )
            }
            
            if meal.amount > 0 {
                VStack {
                    Text("Total meal").font(.headline)
                    
                    HStack {
                        VStack {
                            HStack {
                                Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.carbs))!)
                                Text("g")
                            }
                            Text("Carbs").font(.caption)
                        }
                        
                        VStack {
                            HStack {
                                Text(FoodItemViewModel.doubleFormatter(numberOfDigits: 1).string(from: NSNumber(value: self.meal.fpus.getExtendedCarbs()))!)
                                Text("g")
                            }
                            Text("Extended Carbs").font(.caption)
                        }
                        
                        VStack {
                            HStack {
                                Text(NumberFormatter().string(from: NSNumber(value: self.meal.fpus.getAbsorptionTime(absorptionScheme: self.absorptionScheme)))!)
                                Text("h")
                            }
                            Text("Absorption Time").font(.caption)
                        }
                    }
                }
                .onTapGesture {
                    self.activeSheet = .showMealDetails
                    self.showingSheet = true
                }
                .foregroundColor(.red)
            }
        }
        .sheet(isPresented: $showingSheet) {
            FoodListSheets(
                activeSheet: self.activeSheet,
                isPresented: self.$showingSheet,
                draftFoodItem: self.draftFoodItem,
                draftAbsorptionScheme: AbsorptionSchemeViewModel(from: self.absorptionScheme),
                absorptionScheme: self.absorptionScheme,
                meal: self.meal
            )
                .environment(\.managedObjectContext, self.managedObjectContext)
        }
        .onAppear {
            if self.absorptionScheme.absorptionBlocks.isEmpty {
                // Absorption scheme hasn't been loaded yet
                if self.absorptionBlocks.isEmpty {
                    // Absorption blocks are empty, so initialize with default absorption scheme
                    // and store default blocks back to core data
                    let defaultAbsorptionBlocks = DataHelper.loadDefaultAbsorptionBlocks()
                    
                    for absorptionBlock in defaultAbsorptionBlocks {
                        let cdAbsorptionBlock = AbsorptionBlock(context: self.managedObjectContext)
                        cdAbsorptionBlock.absorptionTime = Int64(absorptionBlock.absorptionTime)
                        cdAbsorptionBlock.maxFpu = Int64(absorptionBlock.maxFpu)
                        self.absorptionScheme.addToAbsorptionBlocks(newAbsorptionBlock: cdAbsorptionBlock)
                    }
                    try? AppDelegate.viewContext.save()
                } else {
                    // Store absorption blocks loaded from core data
                    self.absorptionScheme.absorptionBlocks = self.absorptionBlocks.sorted()
                }
            }
        }
    }
    
    func deleteFoodItem(at offsets: IndexSet) {
        offsets.forEach { index in
            let foodItem = self.foodItems[index]
            self.managedObjectContext.delete(foodItem)
        }
        
        try? AppDelegate.viewContext.save()
    }
}
