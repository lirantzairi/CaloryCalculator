//
//  RoleUpgradeRequest.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/17/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit

class RoleUpgradeRequest: NSObject
{
    var userId: String
    var email: String
    var requestedRole: UserRole

    init(userId: String, email: String, requestedRole: UserRole)
    {
        self.userId = userId
        self.email = email
        self.requestedRole = requestedRole
    }
}

