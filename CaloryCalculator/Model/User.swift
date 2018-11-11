//
//  User.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/11/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit

class User: NSObject
{
    var name: String
    var settings: UserSettings
    var meals: [Meal]
    
    init (name: String, settings: UserSettings, meals: [Meal])
    {
        self.name = name
        self.settings = settings
        self.meals = meals
        
        super.init()
    }
}
