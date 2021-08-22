//
//  SplashController.swift
//  Expense Tracker
//
//  Created by Vvk on 22/08/21.
//

import UIKit

class SplashController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // your code here
            self.loadNavigationStack()
        }
    }
    
    func loadNavigationStack() {
        
        
        if let loggedUser = UserDefaults.standard.value(forKey: "loggedUser") as? String {
            
            print("Move to home: loggedUser \(loggedUser)")
            if let home = self.storyboard?.instantiateViewController(identifier: "HomeController") {
                
                let navigationController = UINavigationController.init(rootViewController: home)
                self.view.window?.rootViewController = navigationController
            }
        }
        else {
            
            print("Move to login")
            if let login = self.storyboard?.instantiateViewController(identifier: "LoginController") {
                
                let navigationController = UINavigationController.init(rootViewController: login)
                navigationController.navigationBar.isHidden = true
                self.view.window?.rootViewController = navigationController
            }
        }
        
    }

}
