//
//  NewsHistoryTableViewController.swift
//  VideoPlayer
//
//  Created by Hai Le on 4/24/18.
//  Copyright © 2018 Hai Le. All rights reserved.
//

import UIKit

private let reuseIdentifier = "NewsHistoryCellIdentifier"

protocol NewsHistoryTableViewControllerDelegate {
    func didSelectHistory(_ history: NewsHistory)
}
class NewsHistoryTableViewController: UITableViewController {
    
    var showFavorites: Bool = false
    var newsHistories: [NewsHistory]!
    var delegate: NewsHistoryTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if showFavorites {
            self.navigationItem.title = "Favorites"
            self.newsHistories = ModelManager.shared.fetchObjects(NewsHistory.self, filter: NSPredicate(format: "isFavorites == %@", NSNumber(value: showFavorites))).sorted(byKeyPath: "dateUpdated", ascending: false).map({$0})
        } else {
            self.navigationItem.title = "History"
            self.newsHistories = ModelManager.shared.fetchObjects(NewsHistory.self).sorted(byKeyPath: "dateUpdated", ascending: false).map({$0})
        }
        self.updateNavigationItem()
        self.tableView.register(cellType: SubTableViewCell.self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateNavigationItem() {
        let leftButtonItem = UIBarButtonItem(image: Asset.General.iconClose.image, style: .done, target: self, action: #selector(closeView))
        self.navigationItem.leftBarButtonItem = leftButtonItem
    }
    
    @objc func closeView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.newsHistories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SubTableViewCell.self)
        let newHistory = self.newsHistories[indexPath.row]
        cell.textLabel?.text = newHistory.name
        cell.detailTextLabel?.text = newHistory.papeURL
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newHistory = self.newsHistories[indexPath.row]
        self.delegate?.didSelectHistory(newHistory)
        self.closeView()
    }

}
