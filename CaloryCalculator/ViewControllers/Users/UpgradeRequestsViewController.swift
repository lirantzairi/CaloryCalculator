//
//  UpgradeRequestsViewController.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/14/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit

class UpgradeRequestsViewController: UIViewController
{
    @IBOutlet private weak var upgradeRequestsTableView: UITableView!
    
    // Injected:
    var user: User!
    var serverConnector: ServerConnector!
    
    private var upgradeRequests = [RoleUpgradeRequest]()
    {
        didSet
        {
            presentedViewController?.dismiss(animated: true, completion: nil)
            upgradeRequestsTableView.reloadData()
        }
    }
    
    deinit
    {
        serverConnector.stopObservingRoleUpgradeRequests(upTo: user.role)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        Preloader.show()
        serverConnector.startObservingRoleUpgradeRequests(upTo: user.role, { [weak self] upgradeRequests in
            Preloader.hide()
            
            guard let sself = self,
                let upgradeRequests = upgradeRequests else
            {
                return
            }
            
            sself.upgradeRequests = upgradeRequests
        })
    }
}

extension UpgradeRequestsViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return upgradeRequests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.UsersManager.upgradeRequestsTableViewCellIdentifier, for: indexPath) as! UpgradeRequestsTableViewCell
        
        cell.configure(withEmail: upgradeRequests[indexPath.row].email)
        cell.selectionStyle = .none
        
        return cell
    }
}

extension UpgradeRequestsViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let upgradeRequest = upgradeRequests[indexPath.row]
        
        Preloader.show()
        serverConnector.getUser(withId: upgradeRequest.userId, { [weak self] user in
            Preloader.hide()
            
            guard let sself = self,
                let user = user else
            {
                return
            }
            
            sself.popUpUpgradeRequest(for: user, to: upgradeRequest.requestedRole)
        })
    }
    
    private func popUpUpgradeRequest(for user: User, to role: UserRole)
    {
        let message = "Name: \(user.name)\nCurrent role: \(user.role)\nRequested role: \(role)"
        
        let alertController = UIAlertController(title: user.email, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Approve", style: .default, handler: { [weak self] _ in
            self?.serverConnector.approveRoleUpgradeRequest(forUserId: user.uid, to: role)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}
