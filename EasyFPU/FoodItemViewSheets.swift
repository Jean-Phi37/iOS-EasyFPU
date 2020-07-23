//
//  FoodListSheets.swift
//  EasyFPU
//
//  Created by Ulrich Rüth on 14.07.20.
//  Copyright © 2020 Ulrich Rüth. All rights reserved.
//

import SwiftUI

enum ActiveFoodItemViewSheet {
    case editFoodItem, selectFoodItem
}

struct FoodItemViewSheets: View {
    @EnvironmentObject var userData: UserData
    @Environment(\.managedObjectContext) var managedObjectContext
    var activeSheet: ActiveFoodItemViewSheet
    @Binding var isPresented: Bool
    @Binding var draftFoodItem: FoodItemViewModel
    var editedFoodItem: FoodItem?
    
    var body: some View {
        switch activeSheet {
        case .editFoodItem:
            return AnyView(
                FoodItemEditor(
                    isPresented: self.$isPresented,
                    draftFoodItem: self.$draftFoodItem,
                    editedFoodItem: self.editedFoodItem
                ).environment(\.managedObjectContext, managedObjectContext)
            )
        case .selectFoodItem:
            return AnyView(
                FoodItemSelector(isPresented: self.$isPresented, amountAsString: String(editedFoodItem!.amount), editedFoodItem: editedFoodItem!)
            )
        }
    }
}