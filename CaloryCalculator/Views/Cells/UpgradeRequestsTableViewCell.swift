//
//  UpgradeRequestsTableViewCell.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/14/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit

class UpgradeRequestsTableViewCell: UITableViewCell
{
    @IBOutlet private weak var emailLabel: UILabel!
    
    func configure(withEmail email: String)
    {
        emailLabel.text = email
    }
}
