//
//  UsersManagerViewController.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/14/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit

class UsersManagerViewController: UIViewController
{
    // Injected:
    var user: User!
    var serverConnector: ServerConnector!
    
    // Passed to user details vc:
    private var inspectedUser: User?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        
        if let tabBarController = segue.destination as? UITabBarController
        {
            if let usersListViewController = tabBarController.viewControllers?[0] as? UsersListViewController,
                let upgradeRequestsViewController = tabBarController.viewControllers?[1] as? UpgradeRequestsViewController
            {
                usersListViewController.user = user
                usersListViewController.serverConnector = serverConnector
                usersListViewController.delegate = self
                
                upgradeRequestsViewController.user = user
                upgradeRequestsViewController.serverConnector = serverConnector
            }
        }
        else if let userDetailsViewController = segue.destination as? UserDetailsViewController
        {
            userDetailsViewController.appUser = user
            userDetailsViewController.inspectedUser = inspectedUser
            userDetailsViewController.serverConnector = serverConnector
        }
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton)
    {
        navigationController?.popViewController(animated: true)
    }
}

extension UsersManagerViewController: UsersListViewControllerDelegate
{
    func didTap(user: User)
    {
        inspectedUser = user
        performSegue(withIdentifier: Constants.Segues.usersManagerToUserDetailsSegue, sender: self)
    }
    
    func didTapAddUser()
    {
        inspectedUser = nil
        performSegue(withIdentifier: Constants.Segues.usersManagerToUserDetailsSegue, sender: self)
    }
    
    func didSetUsers()
    {
        navigationController?.popToViewController(self, animated: true)
    }
}
