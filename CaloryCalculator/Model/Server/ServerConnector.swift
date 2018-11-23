//
//  ServerConnector.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/11/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import Foundation

protocol ServerConnector
{
    // Observing server
    func startObservingMeals(forUserId userId: String, _ completion: @escaping ([Meal]?) -> ())
    func stopObservingMeals(forUserId userId: String)
    func startObservingUsers(_ completion: @escaping ([User]?) -> ())
    func stopObservingUsers()
    func startObservingUser(userId: String, _ completion: @escaping (User?) -> ())
    func stopObservingUser(userId: String)
    func startObservingRoleUpgradeRequests(upTo role: UserRole, _ completion: @escaping ([RoleUpgradeRequest]?) -> ())
    func stopObservingRoleUpgradeRequests(upTo role: UserRole)
    
    // Users
    func createUser(_ user: User, _ completion: @escaping () -> ())
    func getUser(withId id: String, _ completion: @escaping (User?) -> ())
    func getUser(withEmail email: String, _ completion: @escaping (User?) -> ())
    func doesUserExist(withEmail email: String, _ completion: @escaping (Bool?) -> ())
    func getUsers(_ completion: @escaping ([User]?) -> ())
    func updateUser(withId id: String, to user: User, _ completion: @escaping () -> ())
    func deleteUser(withId id: String, _ completion: @escaping () -> ())
    
    // Meals
    func createMeal(_ meal: Meal, _ completion: @escaping () -> ())
    func getMeal(withId id: String, _ completion: @escaping (Meal?) -> ())
    func getMeals(forUserId userId: String, _ completion: @escaping ([Meal]?) -> ())
    func updateMeal(withId id: String, to meal: Meal, _ completion: @escaping () -> ())
    func deleteMeal(withId id: String, _ completion: @escaping () -> ())
    
    // Role upgrade requests
    func requestRoleUpgrade(_ roleUpgradeRequest: RoleUpgradeRequest)
    func getRoleUpgradeRequests(upTo role: UserRole, _ completion: @escaping ([RoleUpgradeRequest]?) -> ())
    func approveRoleUpgradeRequest(forUserId userId: String, to role: UserRole)
}
