//
//  TableViewController.swift
//  SearchForIt
//
//  Created by Lama on 23/01/2019.
//  Copyright © 2019 Lama. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.text = searchText
        }
    }
    
        var photosModel = [Array<Photo>]() {
        didSet {
            table.reloadData()
        }
    }
    
    var searchText: String? {
        didSet {
            photosModel.removeAll()
            search(forText: searchText!, section: 1)
            createData()
            title = searchText
        }
}

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchText = searchBar.text
    }
    
    fileprivate var activeRequest = false
    
    private struct Storyboard {
        static let ShowDetailsSegue = "ShowDetails"
        static let FlickrTableViewCellIdentifier = "FlickrTableViewCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        photosModel.removeAll()
        title = "Search again"
    }
    
    fileprivate func search(forText textToSearch: String, section: Int) {
        if !activeRequest {
            activeRequest = true
            DataProvider.fetchPhotos(searchText: textToSearch, section: section, onCompletion: { (error: DataProviderError?, flickrPhotos: [Photo]?) -> Void in
                
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
                if error == nil {
                    if flickrPhotos!.isEmpty && self.photosModel.isEmpty {
                        let alert = UIAlertController(
                            title: "Sorry",message: "Your search for '\(textToSearch)' didn't return any results.",
                            preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        
                        DispatchQueue.main.async { [unowned unownedSelf = self] in
                            unownedSelf.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        DispatchQueue.main.async { [unowned unownedSelf = self] in
                            unownedSelf.photosModel.append(flickrPhotos!)
                        }
                    }
                    DispatchQueue.main.async { [unowned unownedSelf = self] in
                        unownedSelf.title = textToSearch
                        unownedSelf.tableView.reloadData()
                    }
                } else {
                    if case let DataProviderError.fetching(flickrFail) = error! {
                        let alert = UIAlertController(
                            title: "Oops",
                            message: flickrFail.message,
                            preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        
                        DispatchQueue.main.async { [unowned unownedSelf = self] in
                            unownedSelf.present(alert, animated: true, completion: nil)
                        }
                    }
                    if case let DataProviderError.network(errorMessage) = error! {
                        let alert = UIAlertController(
                            title: "Oops",
                            message: errorMessage,
                            preferredStyle: UIAlertController.Style.alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        
                        DispatchQueue.main.async { [unowned unownedSelf = self] in
                            unownedSelf.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                self.activeRequest = false
            })
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return photosModel.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosModel[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: Storyboard.FlickrTableViewCellIdentifier, for: indexPath as IndexPath)
        
        let flickrPhoto = photosModel[indexPath.section][indexPath.row]
        
        if let flickrCell = cell as? TableViewCell {
            flickrCell.flickrPhoto = flickrPhoto
        }
        
        currentPage = indexPath.section + 1
        
        return cell
    }
    
    fileprivate var currentPage = 0
    fileprivate var lastPage: Int {
        return photosModel.count
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height
        
        if currentOffset > maximumOffset - scrollView.frame.size.height {
            if currentPage == lastPage {
                if searchText != nil {
                    search(forText: searchText!, section: currentPage + 1)
                }
            }
        }
    }
    
    func createData(){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let searchEntity = NSEntityDescription.entity(forEntityName: "SearchHistory", in: managedContext)!
        
        
        let SearcHistory = NSManagedObject(entity: searchEntity, insertInto: managedContext)
        SearcHistory.setValue(searchText, forKeyPath: "keyword")
        
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Storyboard.ShowDetailsSegue {
            if let vc = segue.destination as? DetailsViewController {
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    vc.imageURL = photosModel[selectedIndexPath.section][selectedIndexPath.row].photoLargeUrl
                    vc.title = photosModel[selectedIndexPath.section][selectedIndexPath.row].title
                   
                }
            }
        }
    }

}
