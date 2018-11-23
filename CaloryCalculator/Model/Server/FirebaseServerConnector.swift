//
//  FirebaseServerConnector.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/11/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit
import Firebase

class FirebaseServerConnector: NSObject, ServerConnector
{
    let ref: DatabaseReference = Database.database().reference()
    let firebaseObjectConverter = FirebaseObjectConverter()
    
    
    // MARK: ### Observing server
    
    func startObservingMeals(forUserId userId: String, _ completion: @escaping ([Meal]?) -> ())
    {
        ref.child("meals").queryOrdered(byChild: "userId").queryEqual(toValue: userId).observe(.value, with: { [weak self] snapshot in
            guard let sself = self,
                let meals = sself.extractMeals(from: snapshot) else
            {
                completion(nil)
                return
            }
            
            completion(meals)
        })
    }
    
    func stopObservingMeals(forUserId userId: String)
    {
        ref.child("meals").queryOrdered(byChild: "userId").queryEqual(toValue: userId).removeAllObservers()
    }
    
    func startObservingUsers(_ completion: @escaping ([User]?) -> ())
    {
        ref.child("users").observe(.value, with: { [weak self] snapshot in
            guard let sself = self,
                let users = sself.extractUsers(from: snapshot) else
            {
                completion(nil)
                return
            }
            
            completion(users)
        })
    }
    
    func stopObservingUsers()
    {
        ref.child("users").removeAllObservers()
    }
    
    func startObservingRoleUpgradeRequests(upTo role: UserRole, _ completion: @escaping ([RoleUpgradeRequest]?) -> ())
    {
        ref.child("roleUpgradeRequests").queryOrdered(byChild: "requestedRole").queryEnding(atValue: role.rawValue).observe(.value, with: { [weak self] snapshot in
            guard let sself = self,
                let roleUpgradeRequests = sself.extractRoleUpgradeRequests(from: snapshot) else
            {
                completion(nil)
                return
            }
            
            completion(roleUpgradeRequests)
        })
    }
    
    func stopObservingRoleUpgradeRequests(upTo role: UserRole)
    {
        ref.child("roleUpgradeRequests").queryOrdered(byChild: "requestedRole").queryEnding(atValue: role.rawValue).removeAllObservers()
    }
    
    func startObservingUser(userId: String, _ completion: @escaping (User?) -> ())
    {
        ref.child("users").child(userId).observe(.value, with: { [weak self] snapshot in
            if !snapshot.exists()
            {
                completion(nil)
                return
            }
            
            guard let sself = self,
                let appUser = sself.firebaseObjectConverter.toUser(from: snapshot) else
            {
                completion(nil)
                return
            }
            
            completion(appUser)
        })
    }
    
    func stopObservingUser(userId: String)
    {
        ref.child("users").child(userId).removeAllObservers()
    }
    
    
    // MARK: ### User
    
    func createUser(_ user: User, _ completion: @escaping () -> ())
    {
        let userInfo = firebaseObjectConverter.toServer(from: user)
        ref.child("users").child(user.uid).setValue(userInfo, withCompletionBlock: { _, _ in
            completion()
        })
    }
    
    func getUser(withId id: String, _ completion: @escaping (User?) -> ())
    {
        ref.child("users").child(id).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let sself = self,
                let user = sself.firebaseObjectConverter.toUser(from: snapshot) else
            {
                completion(nil)
                return
            }
            completion(user)

        })
    }
    
    func getUser(withEmail email: String, _ completion: @escaping (User?) -> ())
    {
        ref.child("users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let childSnapshot = snapshot.children.allObjects.first as? DataSnapshot,
                let user = self?.firebaseObjectConverter.toUser(from: childSnapshot) else
            {
                completion(nil)
                return
            }
            completion(user)
        })
    }
    
    func doesUserExist(withEmail email: String, _ completion: @escaping (Bool?) -> ())
    {
        ref.child("users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value, with: { snapshot in
            completion(snapshot.hasChildren())
        })
    }
    
    func getUsers(_ completion: @escaping ([User]?) -> ())
    {
        ref.child("users").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let sself = self,
                let users = sself.extractUsers(from: snapshot) else
            {
                completion(nil)
                return
            }
            
            completion(users)
        })
    }
    
    func updateUser(withId id: String, to user: User, _ completion: @escaping () -> ())
    {
        let userInfo = firebaseObjectConverter.toServer(from: user)
        if id == user.uid
        {
            ref.child("users").child(id).updateChildValues(userInfo, withCompletionBlock: { _, _ in
                completion()
            })
        }
        else
        {
            ref.child("users").child(id).observeSingleEvent(of: .value, with: { [weak self] snapshot in
                self?.ref.child("users").child(user.uid).setValue(snapshot.value);
                snapshot.ref.removeValue()
                
                self?.ref.child("roleUpgradeRequests").child(id).observeSingleEvent(of: .value, with: { [weak self] snapshot in
                    self?.ref.child("roleUpgradeRequests").child(user.uid).setValue(snapshot.value);
                    snapshot.ref.removeValue()
                    
                    self?.ref.child("meals").queryOrdered(byChild: "userId").queryEqual(toValue: id).observeSingleEvent(of: .value, with: { snapshot in
                        for case let childSnapshot as DataSnapshot in snapshot.children
                        {
                            childSnapshot.ref.child("userId").setValue(user.uid)
                        }
                        
                        completion()
                    })
                })
            })
        }
    }
    
    func deleteUser(withId id: String, _ completion: @escaping () -> ())
    {
        ref.child("users").child(id).removeValue(completionBlock: { [weak self] _, _ in
            self?.ref.child("roleUpgradeRequests").child(id).removeValue(completionBlock: { _, _ in
                self?.ref.child("meals").queryOrdered(byChild: "userId").queryEqual(toValue: id).observeSingleEvent(of: .value, with: { snapshot in
                    for case let childSnapshot as DataSnapshot in snapshot.children
                    {
                        childSnapshot.ref.removeValue()
                    }
                    completion()
                })
            })
        })
    }
    
    
    // MARK: ### Meals
    
    func createMeal(_ meal: Meal, _ completion: @escaping () -> ())
    {
        let mealInfo = firebaseObjectConverter.toServer(from: meal)
        ref.child("meals").child(meal.id).setValue(mealInfo, withCompletionBlock: { _, databaseReference in
            completion()
        })
    }
    
    func getMeal(withId id: String, _ completion: @escaping (Meal?) -> ())
    {
        ref.child("meals").child(id).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let sself = self,
                let meal = sself.firebaseObjectConverter.toMeal(from: snapshot) else
            {
                completion(nil)
                return
            }
            completion(meal)
        })
    }
    
    func getMeals(forUserId userId: String,_ completion: @escaping ([Meal]?) -> ())
    {
        ref.child("meals").queryOrdered(byChild: "userId").queryEqual(toValue: userId).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let sself = self,
                let meals = sself.extractMeals(from: snapshot) else
            {
                completion(nil)
                return
            }
            
            completion(meals)
        })
    }
    
    func updateMeal(withId id: String, to meal: Meal, _ completion: @escaping () -> ())
    {
        let mealInfo = firebaseObjectConverter.toServer(from: meal)
        ref.child("meals").child(id).setValue(mealInfo, withCompletionBlock: { _, _ in
            completion()
        })
    }
    
    func deleteMeal(withId id: String, _ completion: @escaping () -> ())
    {
        ref.child("meals").child(id).removeValue(completionBlock: { _, _ in
            completion()
        })
    }
    
    
    // MARK: ### Role Upgrade Requests
    
    func requestRoleUpgrade(_ roleUpgradeRequest: RoleUpgradeRequest)
    {
        let roleUpgradeRequestInfo = firebaseObjectConverter.toServer(from: roleUpgradeRequest)
        ref.child("roleUpgradeRequests").child(roleUpgradeRequest.userId).setValue(roleUpgradeRequestInfo)
    }
    
    func getRoleUpgradeRequests(upTo role: UserRole, _ completion: @escaping ([RoleUpgradeRequest]?) -> ())
    {
        ref.child("roleUpgradeRequests").queryOrdered(byChild: "requestedRole").queryEnding(atValue: role.rawValue).observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let sself = self,
                let roleUpgradeRequests = sself.extractRoleUpgradeRequests(from: snapshot) else
            {
                completion(nil)
                return
            }
            
            completion(roleUpgradeRequests)
        })
    }
    
    func approveRoleUpgradeRequest(forUserId userId: String, to role: UserRole)
    {
        ref.child("roleUpgradeRequests").child(userId).removeValue()
        ref.child("users").child(userId).child("role").setValue(role.rawValue)
    }
    
    // MARK: ### Data from snapshots extractors
    
    private func extractUsers(from snapshot: DataSnapshot) -> [User]?
    {
        var users = [User]()
        for case let childSnapshot as DataSnapshot in snapshot.children
        {
            guard let user = firebaseObjectConverter.toUser(from: childSnapshot) else
            {
                return nil
            }
            
            users.append(user)
        }
        
        return users
    }
    
    private func extractRoleUpgradeRequests(from snapshot: DataSnapshot) -> [RoleUpgradeRequest]?
    {
        var requests = [RoleUpgradeRequest]()
        for case let childSnapshot as DataSnapshot in snapshot.children
        {
            guard let request = firebaseObjectConverter.toRoleUpgradeRequest(from: childSnapshot) else
            {
                return nil
            }
            
            requests.append(request)
        }
        
        return requests
    }
    
    private func extractMeals(from snapshot: DataSnapshot) -> [Meal]?
    {
        var meals = [Meal]()
        for case let childSnapshot as DataSnapshot in snapshot.children
        {
            guard let meal = firebaseObjectConverter.toMeal(from: childSnapshot) else
            {
                return nil
            }
            
            meals.append(meal)
        }
        
        return meals
    }
}
