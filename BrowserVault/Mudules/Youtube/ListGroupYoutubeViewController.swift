//
//  ListGroupYoutubeViewController.swift
//  TopSongs
//
//  Created by Hai Le on 4/22/17.
//  Copyright © 2017 SmartGreenSolution. All rights reserved.
//

import UIKit

class ListGroupYoutubeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var dataSource = GroupYoutubeDataSource()
    weak var delegate: YoutubeViewInterface!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self.dataSource
        self.tableView.delegate = self.dataSource
        self.dataSource.delegate = delegate
        BaseTableViewCell.registerStandardCellsToTableView(self.tableView)
        self.title = "Select Categories"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

