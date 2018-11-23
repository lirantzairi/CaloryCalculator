//
//  ViewController.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/18/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit

extension UIViewController
{
    func hideKeyboardWhenTappedAround()
    {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    func popUpMessage(message: String)
    {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}
