//
//  AuthenticationViewController.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/11/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

extension Notification.Name
{
    static let userDidSignInWithGoogle = Notification.Name("UserDidSignInWithGoogle")
    static let userDidSignOut = Notification.Name("UserDidSignOut")
}

class AuthenticationViewController: UIViewController, GIDSignInUIDelegate
{
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    
    private var user: User?
    {
        didSet
        {
            if let user = user
            {
                serverConnector.startObservingUser(userId: user.uid, { [weak self] user in
                    guard let sself = self, let appUser = sself.user else
                    {
                        return
                    }
                    
                    let isCriticalChange = user == nil || appUser.uid != user!.uid || appUser.email != user!.email
                    if isCriticalChange
                    {
                        sself.popUpWarningAndSignOut()
                    }
                })
            }
            else if let oldValue = oldValue
            {
                serverConnector.stopObservingUser(userId: oldValue.uid)
            }
        }
    }
    
    private var serverConnector: ServerConnector!
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
        if let user = user
        {
            serverConnector.stopObservingUser(userId: user.uid)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        
        if let userProfileViewController = segue.destination as? UserProfileViewController
        {
            userProfileViewController.user = user
            userProfileViewController.serverConnector = serverConnector
            userProfileViewController.delegate = self
        }
        else if let userDetailsViewController = segue.destination as? UserDetailsViewController
        {
            userDetailsViewController.serverConnector = serverConnector
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        serverConnector = FirebaseServerConnector()
        
        Preloader.show()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidSignInWithGoogle(_:)), name: .userDidSignInWithGoogle, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDidSignOut(_:)), name: .userDidSignOut, object: nil)
    }
    
    private func popUpWarningAndSignOut()
    {
        let message = "User has been logged out. Please re-sign in"
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] _ in
            self?.signOut()
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func userDidSignInWithGoogle(_ notification: Notification)
    {
        Preloader.show()
        
        guard let isNewUser = notification.userInfo?[Constants.GoogleUserParams.isNewUser] as? Bool,
            let uid = notification.userInfo?[Constants.GoogleUserParams.uid] as? String,
            let name = notification.userInfo?[Constants.GoogleUserParams.name] as? String,
            let email = notification.userInfo?[Constants.GoogleUserParams.email] as? String
        else
        {
            return
        }
        
        if isNewUser
        {
            let user = User(uid: uid, name: name, email: email, role: .regular, expectedCaloriesADay: Constants.User.initialExcpectedCaloriesADay)
            serverConnector.createUser(user, { [weak self] in
                Preloader.hide()
                
                guard let sself = self else
                {
                    return
                }
                
                sself.user = user
                sself.performSegue(withIdentifier: Constants.Segues.authenticationToUserProfileSegue, sender: self)
            })
        }
        else
        {
            serverConnector.getUser(withId: uid, { [weak self] user in
                Preloader.hide()
                
                guard let sself = self, let user = user else
                {
                    return
                }
                
                sself.user = user
                sself.performSegue(withIdentifier: Constants.Segues.authenticationToUserProfileSegue, sender: self)
            })
        }
    }
    
    /*
     Algorithm:
     1. Validate that user-email exists in database by trying to get the user according to his email.
     2. Try to sign in to Firebase Auth. If succeeded, get user from database and move to next screen. Else, if account doesn't exist (17011):
     3. This means that the user was created by another user. He exists in database but doesn't have an account in Firebase Auth. Therefore:
     4. Create an account in Firebase Auth.
     5. Update user's uid in database according to uid received from Firebase Auth.
     
     The reason for this complex algorithm is Firebase's limitation that we cannot create a user account without signing out from the current one. Therefore, when an admin/manager creates the user, a new user will be created only in database and his account will be created in Firebase Auth on his first log in.
     
     See also: UserDetailsViewController.create()
     */
    @IBAction private func didTapSignInButton(_ sender: UIButton)
    {
        Preloader.show()
        
        serverConnector.getUser(withEmail: emailTextField.text!, { [weak self] user in
            guard let sself = self else
            {
                Preloader.hide()
                return
            }
            
            guard let user = user else
            {
                Preloader.hide()
                sself.popUpMessage(message: "Email does not exist")
                return
            }
            
            Auth.auth().signIn(withEmail: sself.emailTextField.text!, password: sself.passwordTextField.text!) { [weak self] authResult, error in
                guard let sself = self else
                {
                    Preloader.hide()
                    return
                }
                
                if let error = error
                {
                    if error._code == 17009
                    {
                        Preloader.hide()
                        sself.popUpMessage(message: "Incorrect password. In case this is your first login, an old user with the same email still exists on server. In that case, please use a different email.")
                    }
                    else if error._code == 17011
                    {
                        Auth.auth().createUser(withEmail: sself.emailTextField.text!, password: sself.passwordTextField.text!, completion: { [weak self] authResult, error in
                            guard let sself = self, let authResult = authResult, error == nil else
                            {
                                Preloader.hide()
                                return
                            }
                            
                            let oldId = user.uid
                            user.uid = authResult.user.uid
                            sself.serverConnector.updateUser(withId: oldId, to: user, {
                                Preloader.hide()
                                
                                sself.user = user
                                sself.performSegue(withIdentifier: Constants.Segues.authenticationToUserProfileSegue, sender: self)
                            })
                        })
                    }
                    else
                    {
                        Preloader.hide()
                        print(error.localizedDescription)
                    }
                    
                    return
                }
                
                guard let authResult = authResult else
                {
                    Preloader.hide()
                    return
                }
                
                sself.serverConnector.getUser(withId: authResult.user.uid, { [weak self] user in
                    Preloader.hide()
                    
                    guard let sself = self, let user = user else
                    {
                        return
                    }
                    
                    sself.user = user
                    sself.performSegue(withIdentifier: Constants.Segues.authenticationToUserProfileSegue, sender: self)
                })
            }
        })
    }
    
    @objc private func userDidSignOut(_ notification: Notification)
    {
        signOut()
    }
    
    func signOut()
    {
        user = nil
        navigationController?.popToViewController(self, animated: true)
    }
}

extension AuthenticationViewController: UserProfileViewControllerDelegate
{
    func userWillSignOut()
    {
        user = nil
    }
}
