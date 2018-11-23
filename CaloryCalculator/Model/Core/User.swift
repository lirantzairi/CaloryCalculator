//
//  User.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/11/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit

enum UserRole: Int
{
    case regular = 0
    case manager = 1
    case admin = 2
}

class User: NSObject
{
    var uid: String
    var name: String
    var email: String
    var role: UserRole
    var expectedCaloriesADay: Int
    
    init (uid: String, name: String, email: String, role: UserRole, expectedCaloriesADay: Int)
    {
        self.uid = uid
        self.name = name
        self.email = email
        self.role = role
        self.expectedCaloriesADay = expectedCaloriesADay
        
        super.init()
    }
}
