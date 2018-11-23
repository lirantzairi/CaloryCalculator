//
//  FirebaseObjectConverter.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/12/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit
import Firebase

class FirebaseObjectConverter: NSObject
{
    // to server
    
    func toServer(from user: User) -> [String: Any]
    {
        return ["name": user.name, "email": user.email, "role": user.role.rawValue, "expectedCalories": user.expectedCaloriesADay]
    }
    
    func toServer(from meal: Meal) -> [String: Any]
    {
        return ["date": meal.date.timeIntervalSinceReferenceDate, "text": meal.text, "calories": meal.calories, "userId": meal.userId]
    }
    
    func toServer(from roleUpgradeRequest: RoleUpgradeRequest) -> [String: Any]
    {
        return ["email": roleUpgradeRequest.email, "requestedRole": roleUpgradeRequest.requestedRole.rawValue]
    }
    
    
    // from snapshot
    
    func toUser(from snapshot: DataSnapshot) -> User?
    {
        guard let value = snapshot.value as? [String: Any],
            let name = value["name"] as? String,
            let email = value["email"] as? String,
            let roleInt = value["role"] as? Int,
            let role = UserRole(rawValue: roleInt),
            let expectedCaloriesADay = value["expectedCalories"] as? Int else
        {
            return nil
        }
        
        return User(uid: snapshot.key, name: name, email: email, role: role, expectedCaloriesADay: expectedCaloriesADay)
    }

    func toMeal(from snapshot: DataSnapshot) -> Meal?
    {
        guard let value = snapshot.value as? [String: Any],
            let dateTimeInterval = value["date"] as? TimeInterval,
            let text = value["text"] as? String,
            let calories = value["calories"] as? Int,
            let userId = value["userId"] as? String else
        {
            return nil
        }
        
        let date = Date(timeIntervalSinceReferenceDate: dateTimeInterval)
        
        return Meal(date: date, text: text, calories: calories, userId: userId, id: snapshot.key)
    }
    
    func toRoleUpgradeRequest(from snapshot: DataSnapshot) -> RoleUpgradeRequest?
    {
        guard let value = snapshot.value as? [String: Any],
            let email = value["email"] as? String,
            let requestedRoleInt = value["requestedRole"] as? Int,
            let requestedRole = UserRole(rawValue: requestedRoleInt) else
        {
            return nil
        }
        
        return RoleUpgradeRequest(userId: snapshot.key, email: email, requestedRole: requestedRole)
    }
}
