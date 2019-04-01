//
//  SearchVC.swift
//  SearchForIt
//
//  Created by Lama on 26/01/2019.
//  Copyright © 2019 Lama. All rights reserved.
//

import UIKit
import CoreData


class SearchVC: UITableViewController, UISearchBarDelegate {

    var history = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveData()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        history.removeAll()
        retrieveData()

    }
    
 
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
        cell.keyword.text = history[indexPath.item]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }

    func retrieveData() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SearchHistory")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                history.append(data.value(forKey: "keyword") as! String)
            }
            
        } catch {
            
            print("Failed")
        }
        tableView.reloadData()
    }
    
}
