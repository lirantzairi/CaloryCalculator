//
//  UsersListViewController.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/14/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit

protocol UsersListViewControllerDelegate: class
{
    func didTap(user: User)
    func didTapAddUser()
    func didSetUsers()
}

class UsersListViewController: UIViewController
{
    @IBOutlet private weak var usersTableView: UITableView!
    
    // Injected:
    var user: User!
    var serverConnector: ServerConnector!
    weak var delegate: UsersListViewControllerDelegate?
    
    private var users = [User]()
    {
        didSet
        {
            delegate?.didSetUsers()
            usersTableView.reloadData()
        }
    }
    
    deinit
    {
        serverConnector.stopObservingUsers()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        Preloader.show()
        serverConnector.startObservingUsers({ [weak self] users in
            Preloader.hide()
            
            guard let sself = self,
                let users = users else
            {
                return
            }
            
            sself.users = users
        })
    }
    
    @IBAction private func didTapAddButton(_ sender: UIButton)
    {
        delegate?.didTapAddUser()
    }
}

extension UsersListViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.UsersManager.usersTableViewCellIdentifier, for: indexPath) as! UsersTableViewCell
        
        cell.configure(withEmail: users[indexPath.row].email)
        cell.selectionStyle = .none
        
        return cell
    }
}

extension UsersListViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        delegate?.didTap(user: users[indexPath.row])
    }
}
