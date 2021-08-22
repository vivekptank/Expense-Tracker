//
//  HomeController.swift
//  Expense Tracker
//
//  Created by Vvk on 22/08/21.
//

import UIKit

class HomeController: UIViewController {

    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "My Expenses"
    }
    
    @IBAction func logout(_ sender: Any) {
        
        UserDefaults.standard.removeObject(forKey: "loggedUser")
        UserDefaults.standard.removeObject(forKey: "userid")
        UserDefaults.standard.synchronize()
        
        print("Move to login")
        if let login = self.storyboard?.instantiateViewController(identifier: "LoginController") {
            
            let navigationController = UINavigationController.init(rootViewController: login)
            navigationController.navigationBar.isHidden = true
            self.view.window?.rootViewController = navigationController
        }
    }
    
}
