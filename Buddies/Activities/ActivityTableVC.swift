//
//  ActivityTableVC.swift
//  Buddies
//
//  Created by Luke Meier on 2/8/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import Firebase

class ActivityTableVC: UITableViewController, FilterSearchBarDelegate, ActivityTableDataDelegate {
    // Override the getter for this proprty in a subclass
    // to set the section headers for the TableView:
    var sectionHeaders: [String] = []

    // Fabulous fab:
    var fab: FAB!

    // Data manager and source. The manager controlls the listeners, posting back
    // to this class when changes are made. The data source handles modifying the
    // tableview data source. ActivityTableVC handles the interaction between the
    // two, including calling the TableView refresh methods as needed.
    let dataManager = ActivityTableDataListener()
    let dataSource = ActivityList()

    // MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up data source stuff:
        dataManager.delegate = self
        dataSource.setSectionHeaders(sectionHeaders)
        self.tableView.dataSource = self.dataSource

        // Set up some TableView rendering stuff:
        self.tableView.rowHeight = Theme.activityRowHeight
        self.configureRefreshControl()
        tableView.register(UINib(nibName: "ActivityCell", bundle: nil), forCellReuseIdentifier: "ActivityCell")

        // We need to store a local so that the
        //  instance isn't deallocated along with
        //  the event handler!
        fab = FAB(for: self)
        fab.renderCreateActivityFab()
        
        LocationPersistence.instance.makeSureWeHaveLocationAccess(from: self)
    }
    
    // Calls the subclass implementation whenever the view re-appears
    // to make sure we get the most up-to-date information we need.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAndLoadActivities()
    }
    
    // Clears all the listeners in the data manager:
    deinit {
        dataManager.cleanup()
    }

    func endEditing() {
        self.view.endEditing(false)
    }

    // MARK:- Refresh Control for the TableView:
    func configureRefreshControl () {
        // Add the refresh control to your UIScrollView object.
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        tableView.refreshControl = self.refreshControl
    }
    
    func startRefreshIndicator() {
        // This lets us show the refresh indicator above the list if
        // the table is empty. If there were results, calling this
        // function would move the list height in a weird way.
        if (dataSource.hasNoActivities()) {
            self.refreshControl?.beginRefreshingManually()
        }
        self.refreshControl?.beginRefreshing()
    }

    // Called when the user pulls down to trigger a refresh:
    @objc func handleRefreshControl() {
        self.fetchAndLoadActivities()
    }
    
    // MARK:- Manage queries and query changes.
    // Implemented by the children who handle the actual logic of what activities
    // the child wants to see. When implementing this, please also call
    // `startRefreshIndicator()` at the beginning of the function definition
    func fetchAndLoadActivities() {}
    
    // This function is called to update the IDs that we want to display.
    // It then asks the data accessor for them, which will post back the
    // actual activities we're permitted to use via `onNewActivities`
    func updateWantedActivities(with ids: [[ActivityId]]) {
        self.dataManager.updateWantedActivities(with: ids)
    }

    // MARK:- Table view data source
    func updateActivityInSection(activity: Activity, section: Int) {
        if let path = dataSource.updateActivityInSection(activity: activity, section: section) {
            tableView.reloadRows(at: [path], with: .fade)
        }
    }
    
    func onNewActivities(newActivities: [[Activity]]) {
        if let paths = dataSource.setActivities(newActivities) {
            tableView.deleteRows(at: paths, with: .fade)
        } else {
            tableView.reloadData()
        }
    }
    
    func removeActivityInSection(id: ActivityId, section: Int) {
        if let path = dataSource.removeActivityInSection(id: id, section: section) {
            tableView.deleteRows(at: [path], with: .fade)
        }
    }

    // Called by the data listener when an operation
    // ("new/remove/update" activity) has completed
    func onOperationsFinished() {
        self.refreshControl?.endRefreshing()
        checkAndShowNoActivitiesMessage()
    }

    func checkAndShowNoActivitiesMessage () {
        if ( self.dataSource.hasNoActivities() ) {
            tableView.setEmptyMessage("No results")
        } else {
            tableView.clearBackground()
        }
    }

    // Mark:- Displaying view activity:
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? ActivityCell
        self.performSegue(withIdentifier: "showActivityDetails", sender: cell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectedIndex = self.tableView.indexPath(for: sender as! UITableViewCell)
        if let path = selectedIndex {
            let activityId = dataSource[activityAt: path].activityId
            self.showActivity(with: activityId, for: segue)
        }
    }

    func showActivity(with id: String, for segue: UIStoryboardSegue? = nil) {
        if let segue = segue, let destination = segue.destination as? ViewActivityController {
            destination.loadWith(id)
        } else if let viewActivity = BuddiesStoryboard.ViewActivity.viewController(withID: "viewActivity") as? ViewActivityController {
            viewActivity.loadWith(id)
            // Put the controller somewhere...
            self.navigationController?.pushViewController(viewActivity, animated: true)
        }
    }
}
