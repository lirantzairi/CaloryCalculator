//
//  MealsViewController.swift
//  CaloryCalculator
//
//  Created by Liran Tzairi on 11/14/18.
//  Copyright © 2018 Liran Tzairi. All rights reserved.
//

import UIKit

class MealsViewController: UIViewController
{
    @IBOutlet private weak var mealsTableView: UITableView!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var datePickerView: UIView!
    @IBOutlet private weak var dailyDateTextField: UITextField!
    @IBOutlet private weak var fromDateTextField: UITextField!
    @IBOutlet private weak var toDateTextField: UITextField!
    @IBOutlet private weak var fromTimeTextField: UITextField!
    @IBOutlet private weak var toTimeTextField: UITextField!
    @IBOutlet private weak var dailyView: UIView!
    @IBOutlet private weak var inRangeView: UIView!
    @IBOutlet private weak var totalLabel: UILabel!
    
    private var showingMeal: Meal?
    private var textFieldBeingEdited: UITextField?
    private let dateFormatter = DateFormatter()
    private let timeFormatter = DateFormatter()
    private var mealsTableViewCellColor = UIColor.black
    
    // Injected:
    var user: User!
    var serverConnector: ServerConnector!
    
    private var meals = [Meal]()
    {
        didSet
        {
            presentMealsInTableView()
        }
    }
    
    private var filteredMeals: [Meal]
    {
        if inRangeView.isHidden
        {
            let startDate = dateFormatter.date(from: dailyDateTextField.text!)!
            let endDate = Calendar.current.date(byAdding: .hour, value: 24, to: startDate)!
            
            return meals.filter({ meal in
                startDate <= meal.date && meal.date <= endDate
            })
        }
        
        let fromDate = dateFormatter.date(from: fromDateTextField.text!)!
        let toDate = Calendar.current.date(byAdding: .hour, value: 24, to: dateFormatter.date(from: toDateTextField.text!)!)!
        let fromTime = timeFormatter.date(from: fromTimeTextField.text!)!
        let toTime = timeFormatter.date(from: toTimeTextField.text!)!
        
        return meals.filter({ meal in
            fromDate <= meal.date && meal.date <= toDate && fromTime.isSmallerThanOrEqualToInTime(to: meal.date) && meal.date.isSmallerThanOrEqualToInTime(to: toTime)
        })
    }
    
    deinit
    {
        serverConnector.stopObservingMeals(forUserId: user.uid)
        serverConnector.stopObservingUser(userId: user.uid)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        
        if let mealDetailsViewController = segue.destination as? MealDetailsViewController
        {
            mealDetailsViewController.userId = user.uid
            mealDetailsViewController.meal = showingMeal
            mealDetailsViewController.serverConnector = serverConnector
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        timeFormatter.dateFormat = "hh:mm a"
        
        datePicker.backgroundColor = .lightGray

        let date = Date()
        dailyDateTextField.text = dateFormatter.string(from: date)
        fromDateTextField.text = dailyDateTextField.text
        toDateTextField.text = dailyDateTextField.text
        fromTimeTextField.text = timeFormatter.string(from: date)
        toTimeTextField.text = fromTimeTextField.text
        
        datePickerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideDatePickerView)))
        dailyDateTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showDatePickerView)))
        fromDateTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showDatePickerView)))
        toDateTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showDatePickerView)))
        fromTimeTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showDatePickerView)))
        toTimeTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showDatePickerView)))
        
        serverConnector.startObservingUser(userId: user.uid, { [weak self] user in
            guard user != nil else
            {
                return
            }
            
            self?.presentMealsInTableView()
        })
        serverConnector.startObservingMeals(forUserId: user.uid, { [weak self] meals in
            guard let sself = self, let meals = meals else
            {
                return
            }
            
            sself.meals = meals
        })
    }
    
    private func presentMealsInTableView()
    {
        navigationController?.popToViewController(self, animated: true)
        mealsTableViewCellColor = .black
        
        if meals.isEmpty
        {
            totalLabel.isHidden = true
        }
        else
        {
            let totalCalories = filteredMeals.reduce(0, { result, meal in
                return result + meal.calories
            })
            totalLabel.text = "Total: " + String(totalCalories)
            totalLabel.isHidden = false
            
            if inRangeView.isHidden
            {
                mealsTableViewCellColor = totalCalories <= user.expectedCaloriesADay ? .green : .red
            }
        }
        
        mealsTableView.reloadData()
    }
    
    @objc private func showDatePickerView(_ gestureRecognizer: UIGestureRecognizer)
    {
        guard let textField = gestureRecognizer.view as? UITextField else
        {
            return
        }
        
        if textField == fromDateTextField
        {
            datePicker.minimumDate = nil
            datePicker.maximumDate = dateFormatter.date(from: toDateTextField.text!)
            datePicker.datePickerMode = .date
            datePicker.date = dateFormatter.date(from: textField.text!)!
        }
        else if textField == toDateTextField
        {
            datePicker.minimumDate = dateFormatter.date(from: fromDateTextField.text!)
            datePicker.maximumDate = nil
            datePicker.datePickerMode = .date
            datePicker.date = dateFormatter.date(from: textField.text!)!
        }
        else if textField == fromTimeTextField
        {
            datePicker.minimumDate = nil
            datePicker.maximumDate = timeFormatter.date(from: toTimeTextField.text!)
            datePicker.datePickerMode = .time
            datePicker.date = timeFormatter.date(from: textField.text!)!
        }
        else if textField == toTimeTextField
        {
            datePicker.minimumDate = timeFormatter.date(from: fromTimeTextField.text!)
            datePicker.maximumDate = nil
            datePicker.datePickerMode = .time
            datePicker.date = timeFormatter.date(from: textField.text!)!
        }
        else if textField == dailyDateTextField
        {
            datePicker.minimumDate = nil
            datePicker.maximumDate = nil
            datePicker.datePickerMode = .date
            datePicker.date = dateFormatter.date(from: textField.text!)!
        }
        
        textFieldBeingEdited = gestureRecognizer.view as? UITextField
        datePickerView.isHidden = false
    }
    
    @objc private func hideDatePickerView(_ gestureRecognizer: UIGestureRecognizer)
    {
        datePickerView.isHidden = true
        textFieldBeingEdited = nil
    }
    
    @IBAction private func didTapDailyButton(_ sender: UIButton)
    {
        dailyView.isHidden = false
        inRangeView.isHidden = true
        
        presentMealsInTableView()
    }
    
    @IBAction private func didTapInRangeButton(_ sender: Any)
    {
        dailyView.isHidden = true
        inRangeView.isHidden = false
        
        presentMealsInTableView()
    }
    
    @IBAction private func didChangeDatePickerValue()
    {
        guard let textFieldBeingEdited = textFieldBeingEdited else
        {
            return
        }
        
        let doesTextFieldRepresentTime = textFieldBeingEdited == fromTimeTextField || textFieldBeingEdited == toTimeTextField
        textFieldBeingEdited.text = (doesTextFieldRepresentTime ? timeFormatter : dateFormatter).string(from: datePicker.date)
        
        presentMealsInTableView()
    }
    
    @IBAction private func didTapAddButton(_ sender: Any)
    {
        showingMeal = nil
        performSegue(withIdentifier: Constants.Segues.mealsToMealDetailsSegue, sender: self)
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton)
    {
        navigationController?.popViewController(animated: true)
    }
}

extension MealsViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filteredMeals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell()
        
        let date = filteredMeals[indexPath.row].date
        
        cell.textLabel?.text = dateFormatter.string(from: date) + " " + timeFormatter.string(from: date)
        cell.textLabel?.textColor = mealsTableViewCellColor
        cell.selectionStyle = .none
        
        return cell
    }
}

extension MealsViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        showingMeal = filteredMeals[indexPath.row]
        performSegue(withIdentifier: Constants.Segues.mealsToMealDetailsSegue, sender: self)
    }
}
