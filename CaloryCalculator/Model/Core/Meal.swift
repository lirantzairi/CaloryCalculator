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
    var userId: String
    
    init(date: Date, text: String, calories: Int, userId: String, id: String)
    {
        self.id = id
        self.date = date
        self.text = text
        self.calories = calories
        self.userId = userId
        
        super.init()
    }
}
