//
//  MealDetailsViewController.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/15/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit

class MealDetailsViewController: UIViewController
{
    @IBOutlet private weak var dateTextField: UITextField!
    @IBOutlet private weak var caloriesTextField: UITextField!
    @IBOutlet private weak var descriptionTextField: UITextField!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var datePickerView: UIView!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var stackViewInScrollWidthConstraint: NSLayoutConstraint!
    
    // Injected:
    var userId: String!
    var meal: Meal?
    var serverConnector: ServerConnector!
    
    private let dateFormatter = DateFormatter()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()

        stackViewInScrollWidthConstraint.constant = UIScreen.main.bounds.width - 40
        
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm a"
        
        if let meal = meal
        {
            caloriesTextField.text = String(meal.calories)
            descriptionTextField.text = meal.text
            dateTextField.text = dateFormatter.string(from: meal.date)
        }
        else
        {
            caloriesTextField.text = String(Constants.Meal.initialCalories)
            descriptionTextField.text = Constants.Meal.initialDescription
            dateTextField.text = dateFormatter.string(from: Date())
            
            deleteButton.isHidden = true
        }
        
        datePicker.backgroundColor = .lightGray
        datePickerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideDatePickerView)))
        dateTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showDatePickerView)))
    }
    
    @objc private func showDatePickerView(_ gestureRecognizer: UIGestureRecognizer)
    {
        datePicker.datePickerMode = .dateAndTime
        datePicker.date = dateFormatter.date(from: dateTextField.text!)!
    
        datePickerView.isHidden = false
    }
    
    @objc private func hideDatePickerView(_ gestureRecognizer: UIGestureRecognizer)
    {
        datePickerView.isHidden = true
    }
    
    @IBAction private func didTapCancelButton(_ sender: Any)
    {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func didTapDeleteButton(_ sender: Any)
    {
        Preloader.show()
        serverConnector.deleteMeal(withId: meal!.id, { [weak self] in
            Preloader.hide()
            
            guard let sself = self else
            {
                return
            }
            
            sself.navigationController?.popViewController(animated: true)
        })
    }
    
    @IBAction private func didTapSaveButton(_ sender: Any)
    {
        guard let calories = Int(caloriesTextField.text!) else
        {
            let alertController = UIAlertController(title: nil, message: "Illegal calories input", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            present(alertController, animated: true, completion: nil)
            return
        }
        
        let date = dateFormatter.date(from: dateTextField.text!)!
        let id = meal?.id ?? UUID().uuidString
        let newMeal = Meal(date: date, text: descriptionTextField.text!, calories: calories, userId: userId, id: id)
        
        Preloader.show()
        serverConnector.updateMeal(withId: id, to: newMeal, { [weak self] in
            Preloader.hide()
            
            guard let sself = self else
            {
                return
            }
            
            sself.navigationController?.popViewController(animated: true)
        })
    }
    
    @IBAction private func didChangeDatePickerValue()
    {
        dateTextField.text = dateFormatter.string(from: datePicker.date)
    }
}
