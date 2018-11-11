//
//  UserSettings.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/11/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit

class UserSettings: NSObject
{
    var expectedCaloriesADay: Int
    
    override init()
    {
        expectedCaloriesADay = Constants.UserSettings.initialExcpectedCaloriesADay
        
        super.init()
    }
}
