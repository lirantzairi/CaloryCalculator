//
//  UserSettingsRoleTableViewCell.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/14/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit

class UserSettingsRoleTableViewCell: UITableViewCell
{
    @IBOutlet private weak var roleLabel: UILabel!
    
    func configure(withRole role: String)
    {
        roleLabel.text = role
    }
    
    func selectRole(_ isSelected: Bool)
    {
        roleLabel.textColor = isSelected ? .blue : .black
    }
}
