//
//  Constants.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/11/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit

struct Constants
{
    struct User
    {
        static let initialEmail = "jamesbond@007.com"
        static let initialName = "James Bond"
        static let initialExcpectedCaloriesADay = 2000
        static let rolesTableViewCellIdentifier = "RolesTableViewCellIdentifier"
        static let roles = ["Regular", "Manager", "Admin"]
    }
    
    struct Meal
    {
        static let initialCalories = 500
        static let initialDescription = "My tasty sandwich :)"
    }
    
    struct UsersManager
    {
        static let upgradeRequestsTableViewCellIdentifier = "UpgradeRequestsTableViewCellIdentifier"
        static let usersTableViewCellIdentifier = "UsersTableViewCellIdentifier"
    }
    
    struct Segues
    {
        static let authenticationToUserProfileSegue = "AuthenticationToUserProfileSegue"
        static let userProfileToUsersManagerSegue = "UserProfileToUsersManagerSegue"
        static let userProfileToMealsSegue = "UserProfileToMealsSegue"
        static let usersManagerToUserDetailsSegue = "UsersManagerToUserDetailsSegue"
        static let mealsToMealDetailsSegue = "MealsToMealDetailsSegue"
        static let userDetailsToMealsSegue = "UserDetailsToMealsSegue"
    }
    
    struct Time
    {
        static let secondsInDay = 60 * 60 * 24
    }
    
    struct GoogleUserParams
    {
        static let uid = "uid"
        static let name = "name"
        static let email = "email"
        static let isNewUser = "isNewUser"
    }
}
