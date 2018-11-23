//
//  UserDetailsViewController.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/14/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit
import FirebaseAuth

class UserDetailsViewController: UIViewController
{
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var expectedCaloriesTextField: UITextField!
    @IBOutlet private weak var roleTableView: UITableView!
    @IBOutlet private weak var roleTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var upgradingLabel: UILabel!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var manageMealsButton: UIButton!
    @IBOutlet private weak var scrollContentViewWidthConstraint: NSLayoutConstraint!
    
    // Injected:
    var appUser: User?
    var inspectedUser: User?
    var serverConnector: ServerConnector!
    
    let roles: [UserRole] = [.regular, .manager, .admin]
    var chosenRole = UserRole.regular
    {
        willSet
        {
            if let cell = roleTableView.cellForRow(at: IndexPath(row: chosenRole.rawValue, section: 0)) as? UserSettingsRoleTableViewCell
            {
                cell.selectRole(false)
            }
        }
        didSet
        {
            if let cell = roleTableView.cellForRow(at: IndexPath(row: chosenRole.rawValue, section: 0)) as? UserSettingsRoleTableViewCell
            {
                cell.selectRole(true)
            }
            
            isAskingForRoleUpgrade = (appUser == nil && chosenRole != .regular) ||
                (appUser != nil && inspectedUser == nil && appUser!.role.rawValue < chosenRole.rawValue) ||
                (appUser != nil && inspectedUser != nil && max(inspectedUser!.role.rawValue, appUser!.role.rawValue) < chosenRole.rawValue)
        }
    }
    
    var isAskingForRoleUpgrade = false
    {
        didSet
        {
            upgradingLabel.isHidden = !isAskingForRoleUpgrade
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        
        if let mealsViewController = segue.destination as? MealsViewController
        {
            mealsViewController.user = inspectedUser
            mealsViewController.serverConnector = serverConnector
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()

        if let inspectedUser = inspectedUser, let appUser = appUser
        {
            emailTextField.text = inspectedUser.email
            nameTextField.text = inspectedUser.name
            expectedCaloriesTextField.text = String(inspectedUser.expectedCaloriesADay)
            chosenRole = inspectedUser.role
            
            deleteButton.isHidden = appUser.role.rawValue < UserRole.manager.rawValue || inspectedUser.uid == appUser.uid
            manageMealsButton.isHidden = appUser.role.rawValue < UserRole.admin.rawValue && inspectedUser.uid != appUser.uid
        }
        else
        {
            emailTextField.isEnabled = true
            if appUser == nil
            {
                passwordTextField.isEnabled = true
                passwordTextField.text = ""
            }
            nameTextField.text = Constants.User.initialName
            expectedCaloriesTextField.text = String(Constants.User.initialExcpectedCaloriesADay)
            chosenRole = .regular
            
            deleteButton.isHidden = true
            manageMealsButton.isHidden = true
            saveButton.setTitle("Create", for: .normal)
        }
        
        roleTableView.separatorStyle = .none
        
        scrollContentViewWidthConstraint.constant = UIScreen.main.bounds.width - 40
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        roleTableViewHeightConstraint.constant = roleTableView.contentSize.height
    }
    
    @IBAction func didTapSaveButton(_ sender: UIButton)
    {
        guard let email = validateAndGetEmail(),
            let password = validateAndGetPassword(),
            let name = validateAndGetName(),
            let expectedCalories = validateAndGetExpectedCalories() else
        {
            return
        }
        
        let role = isAskingForRoleUpgrade ? (inspectedUser?.role ?? .regular) : chosenRole
        let uid = (inspectedUser == nil) ? UUID().uuidString : inspectedUser!.uid
        
        let user = User(uid: uid, name: name, email: email, role: role, expectedCaloriesADay: expectedCalories)
        
        if inspectedUser == nil
        {
            create(newUser: user, password: password)
        }
        else
        {
            update(user: user)
        }
    }
    
    private func validateAndGetEmail() -> String?
    {
        if !isLegal(string: emailTextField.text!, accordingToRegEx: "[A-Za-z0-9._%+-]+@[A-Za-z0-9._-]+\\.[A-Za-z]{2,64}")
        {
            popUpMessage(message: "Illegal email input!")
            return nil
        }
        
        return emailTextField.text!
    }
    
    private func validateAndGetPassword() -> String?
    {
        if !isLegal(string: passwordTextField.text!, accordingToRegEx: "[A-Z0-9a-z]{8,64}")
        {
            popUpMessage(message: "Password should be between 8 to 64 chars long, made of uppercase/lowercase letters and/or digits.")
            return nil
        }
        
        return passwordTextField.text!
    }
    
    private func validateAndGetName() -> String?
    {
        if !isLegal(string: nameTextField.text!, accordingToRegEx: "[A-Za-z ]{4,64}")
        {
            popUpMessage(message: "Name should be between 4 to 64 chars long, made of uppercase/lowercase letters and/or spaces.")
            return nil
        }
        
        return nameTextField.text!
    }
    
    private func validateAndGetExpectedCalories() -> Int?
    {
        guard let expectedCaloriesInt = Int(expectedCaloriesTextField.text!) else
        {
            popUpMessage(message: "Illegal Expected Calories input!")
            return nil
        }
        
        return expectedCaloriesInt
    }
    
    private func isLegal(string: String, accordingToRegEx regEx: String) -> Bool
    {
        let test = NSPredicate(format:"SELF MATCHES %@", regEx)
        return test.evaluate(with: string)
    }

    /*
     Algorithm:
     1. Validate that user doesn't exist in database.
     2. Create user in database with dummy uid.
     3. In case we got to this screen from inside a user's account (an admin/manager is creating the user), Stop here. Else:
     4. Create an account in Firebase Auth.
     5. Update user's uid in database according to uid received from Firebase Auth.
     
     The reason for this complex algorithm is Firebase's limitation that we cannot create a user account without signing out from the current one. Therefore, when an admin/manager creates the user, a new user will be created only in database and his account will be created in Firebase Auth on his first log in.
     
     See also: AuthenticationViewController.didTapSignInButton()
     */
    private func create(newUser: User, password: String)
    {
        Preloader.show()
        serverConnector.doesUserExist(withEmail: newUser.email, { [weak self] exists in
            guard let sself = self, let exists = exists else
            {
                Preloader.hide()
                return
            }
            
            if exists
            {
                Preloader.hide()
                sself.popUpMessage(message: "User with this email already exists.")
                return
            }
            
            sself.serverConnector.createUser(newUser, { [weak self] in
                guard let sself = self else
                {
                    Preloader.hide()
                    return
                }
                
                if sself.isAskingForRoleUpgrade
                {
                    let roleUpgradeRequest = RoleUpgradeRequest(userId: newUser.uid, email: newUser.email, requestedRole: sself.chosenRole)
                    sself.serverConnector.requestRoleUpgrade(roleUpgradeRequest)
                }
                
                if sself.appUser != nil
                {
                    Preloader.hide()
                    sself.navigationController?.popViewController(animated: true)
                }
                else
                {
                    Auth.auth().createUser(withEmail: newUser.email, password: password) { [weak self] authResult, error in
                        guard let sself = self else
                        {
                            Preloader.hide()
                            return
                        }
                        
                        guard error == nil, let authResult = authResult else
                        {
                            Preloader.hide()
                            sself.popUpMessage(message: "Error occurred. It might be possible that an old user with the same email still exists. Please try a different email.")
                            return
                        }
                        
                        let oldId = newUser.uid
                        newUser.uid = authResult.user.uid
                        sself.serverConnector.updateUser(withId: oldId, to: newUser, {
                            Preloader.hide()
                            sself.navigationController?.popViewController(animated: true)
                        })
                    }
                }
            })
        })
    }
    
    private func update(user: User)
    {
        Preloader.show()
        serverConnector.updateUser(withId: user.uid, to: user, { [weak self] in
            Preloader.hide()
            
            guard let sself = self else
            {
                return
            }
            
            if sself.isAskingForRoleUpgrade
            {
                let roleUpgradeRequest = RoleUpgradeRequest(userId: user.uid, email: user.email, requestedRole: sself.chosenRole)
                sself.serverConnector.requestRoleUpgrade(roleUpgradeRequest)
            }
            
            sself.navigationController?.popViewController(animated: true)
        })
    }
    
    @IBAction func didTapCancelButton(_ sender: Any)
    {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapDeleteButton(_ sender: Any)
    {
        guard let inspectedUser = inspectedUser,
            appUser?.uid != inspectedUser.uid else
        {
            return
        }
        
        Preloader.show()
        serverConnector.deleteUser(withId: inspectedUser.uid, { [weak self] in
            Preloader.hide()
            
            guard let sself = self else
            {
                return
            }
            
            sself.navigationController?.popViewController(animated: true)
        })
    }
}

extension UserDetailsViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return roles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.User.rolesTableViewCellIdentifier, for: indexPath) as! UserSettingsRoleTableViewCell
        
        cell.configure(withRole: Constants.User.roles[indexPath.row])
        cell.selectRole(indexPath.row == chosenRole.rawValue)
        cell.selectionStyle = .none
        
        return cell
    }
}

extension UserDetailsViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let newRole = UserRole(rawValue: indexPath.row)
        {
            chosenRole = newRole
        }
    }
}
