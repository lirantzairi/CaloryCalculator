//
//  Meal.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/11/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit

class Meal: NSObject
{
    var id: String
    var date: Date
    var text: String
    var calories: Int
    
    init(date: Date, text: String, calories: Int)
    {
        self.id = UUID().uuidString
        self.date = date
        self.text = text
        self.calories = calories
        
        super.init()
    }
}
