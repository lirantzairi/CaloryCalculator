//
//  ServerConnector.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/11/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import Foundation

enum ServerResponse
{
    
}

protocol ServerConnector
{
    func createUser(_ user: User, _ completion: (ServerResponse) -> ())
    func getUser(withId: Int, _ completion: (ServerResponse, User?) -> ())
    func getUsers(_ completion: (ServerResponse, [User]?) -> ())
    func updateUser(withId: String, to user: User, _ completion: (ServerResponse) -> ())
    func deleteUser(withId: String, _ completion: (ServerResponse) -> ())
    
    func createMeal(_ meal: Meal, _ completion: (ServerResponse) -> ())
    func getMeal(withId: Int, _ completion: (ServerResponse, Meal?) -> ())
    func getMeals(_ completion: (ServerResponse, [Meal]?) -> ())
    func updateMeal(withId: String, to meal: Meal, _ completion: (ServerResponse) -> ())
    func deleteMeal(withId: String, _ completion: (ServerResponse) -> ())
}
