//
//  LoginController.swift
//  Expense Tracker
//
//  Created by Vvk on 22/08/21.
//

import UIKit

class LoginController: UIViewController {

    @IBOutlet var txtUsername: UITextField!
    @IBOutlet var txtPasscode: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func loginButtonTap(_ sender: UIButton) {
        
        if txtUsername.text?.isEmpty == true {
            showAlert(message: "Username can not be blank")
        }
        else if txtPasscode.text?.isEmpty == true {
            showAlert(message: "Please enter passcode")
        }
        else {
            
            if let user = appDelegate.dbManager.validateUser(username: txtUsername.text ?? "", passcode: txtPasscode.text ?? "") {
                
                if let username = user.value(forKey: "username") as? String {
                    UserDefaults.standard.setValue(username, forKey: "loggedUser")
                    
                    if let userid = user.value(forKey: "userid") as? String {
                        UserDefaults.standard.setValue(Int(userid), forKey: "userid")
                    }
                    
                    UserDefaults.standard.synchronize()
                    
                    print("Move to home: loggedUser \(username)")
                    if let home = self.storyboard?.instantiateViewController(identifier: "HomeController") {
                        
                        let navigationController = UINavigationController.init(rootViewController: home)
                        self.view.window?.rootViewController = navigationController
                    }
                }
                
            }
            else {
                showAlert(message: "Invalid username or passcode")
            }
        }
    }
    
    @IBAction func createAccountTap(_ sender: UIButton) {
        
        if let signup = self.storyboard?.instantiateViewController(identifier: "SignupController") {
            
            signup.modalPresentationStyle = .fullScreen
            self.present(signup, animated: true, completion: nil)
        }
    }
}
