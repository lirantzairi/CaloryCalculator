//
//  UserProfileViewController.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/11/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

protocol UserProfileViewControllerDelegate: class
{
    func userWillSignOut()
}

class UserProfileViewController: UIViewController
{
    @IBOutlet private weak var manageUsersButton: UIButton!
    @IBOutlet private weak var nameLabel: UILabel!
    
    // Injected:
    var user: User!
    var serverConnector: ServerConnector!
    weak var delegate: UserProfileViewControllerDelegate?
    
    deinit
    {
        serverConnector.stopObservingUser(userId: user.uid)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        
        if let userDetailsViewController = segue.destination as? UserDetailsViewController
        {
            userDetailsViewController.appUser = user
            userDetailsViewController.inspectedUser = user
            userDetailsViewController.serverConnector = serverConnector
        }
        else if let usersManagerViewController = segue.destination as? UsersManagerViewController
        {
            usersManagerViewController.user = user
            usersManagerViewController.serverConnector = serverConnector
        }
        else if let mealsViewController = segue.destination as? MealsViewController
        {
            mealsViewController.user = user
            mealsViewController.serverConnector = serverConnector
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        nameLabel.text = user.name
        
        serverConnector.startObservingUser(userId: user.uid, { [weak self] user in
            guard let sself = self, let user = user else
            {
                return
            }
            
            sself.user.name = user.name
            sself.user.expectedCaloriesADay = user.expectedCaloriesADay
            sself.user.role = user.role
            
            sself.nameLabel.text = user.name
            sself.manageUsersButton.isHidden = user.role == .regular
            
            let currentUser = Auth.auth().currentUser
            currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                if let idToken = idToken
                {
                    print(idToken)
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        manageUsersButton.isHidden = user.role == .regular
    }
    
    @IBAction private func didTapSignOut(_ sender: UIButton)
    {
        delegate?.userWillSignOut()
        
        GIDSignIn.sharedInstance().signOut()
        try? Auth.auth().signOut()
        
        navigationController?.popViewController(animated: true)
    }
}
