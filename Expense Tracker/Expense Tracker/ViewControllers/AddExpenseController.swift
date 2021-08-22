//
//  AddExpenseController.swift
//  Expense Tracker
//
//  Created by Vvk on 22/08/21.
//

import UIKit

class AddExpenseController: UIViewController {

    @IBOutlet var txtTitle: UITextField!
    @IBOutlet var txtAmount: UITextField!
    @IBOutlet var txtDate: UITextField!
    @IBOutlet var txtCategory: UITextField!
    @IBOutlet var txtNotes: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtCategory.delegate = self
    }

    @IBAction func addExpense(_ sender: UIButton) {
        
    }
    
    @IBAction func clear(_ sender: Any) {
        
        txtTitle.text = nil
        txtAmount.text = nil
        txtDate.text = nil
        txtCategory.text = nil
        txtNotes.text = nil
        self.view.endEditing(true)
    }
}

extension AddExpenseController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == txtCategory {
            
            if let categoryVC = self.storyboard?.instantiateViewController(identifier: "CategoryController") as? CategoryController {
                categoryVC.categoryDelegate = self
                self.show(categoryVC, sender: nil)
            }
            return false
        }
        else {
            return true
        }
    }
}

extension AddExpenseController: CategorySelection {
    
    func didSelectCategory(selectedCategory: String) {
        self.txtCategory.text = selectedCategory
    }
}
