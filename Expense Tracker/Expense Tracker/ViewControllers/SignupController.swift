//
//  SignupController.swift
//  Expense Tracker
//
//  Created by Vvk on 22/08/21.
//

import UIKit

class SignupController: UIViewController {

    @IBOutlet var txtUsername: UITextField!
    @IBOutlet var txtPasscode: UITextField!
    @IBOutlet var txtConfirmPasscode: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signupButtonTap(_ sender: UIButton) {
        
        if txtUsername.text?.isEmpty == true {
            showAlert(message: "Username can not be blank")
        }
        else if txtPasscode.text?.isEmpty == true {
            showAlert(message: "Please enter passcode")
        }
        else if txtConfirmPasscode.text?.isEmpty == true {
            showAlert(message: "Please confirm passcode")
        }
        else if txtPasscode.text != txtConfirmPasscode.text {
            showAlert(message: "Passcode do not match, Please confirm passcode")
        }
        else {
            
            if appDelegate.dbManager.getUser(username: txtUsername.text ?? "") != nil {
                showAlert(message: "User already exists, Please try different user name")
            }
            else {
                appDelegate.dbManager.createUser(username: txtUsername.text ?? "", passcode: txtPasscode.text ?? "")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelButtonTap(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
}
