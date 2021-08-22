//
//  CategoryController.swift
//  Expense Tracker
//
//  Created by Vvk on 22/08/21.
//

import UIKit

protocol CategorySelection {
    
    func didSelectCategory(selectedCategory: String)
}

class CategoryController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var categories = NSArray()
    var categoryDelegate: CategorySelection?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Select Category"
        tableView.dataSource = self
        tableView.delegate = self
        categories = appDelegate.dbManager.getCategories() ?? NSArray()
        tableView.reloadData()
    }

}

extension CategoryController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let category = categories.object(at: indexPath.row) as! NSDictionary
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "CategoryCell")
        cell.textLabel?.text = category.value(forKey: "categoryname") as? String ?? ""
        return cell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories.object(at: indexPath.row) as! NSDictionary
        let selectedCategory = category.value(forKey: "categoryname") as? String ?? ""
        categoryDelegate?.didSelectCategory(selectedCategory: selectedCategory)
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
