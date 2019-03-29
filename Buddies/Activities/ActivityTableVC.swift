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
    // MARK:- User and activity data and data management
    // The activities the data accessor has given us for display:
    // This is the data source of the table view:
    
    // Fabulous fab:
    var fab: FAB!

    // Data manager and source. The manager controlls the listeners, posting back
    // to this class when changes are made. This class handles interacting the actual
    // data source and calling the listview stuff
    let dataManager = ActivityTableDataListener()
    let dataSource = ActivityList()

    // MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        dataManager.delegate = self
        
        self.tableView.rowHeight = Theme.activityRowHeight
        self.tableView.dataSource = self.dataSource

        // We need to store a local so that the
        //  instance isn't deallocated along with
        //  the event handler!
        fab = FAB(for: self)
        fab.renderCreateActivityFab()
        
        LocationPersistence.instance.makeSureWeHaveLocationAccess(from: self)
        
        tableView.register(UINib(nibName: "ActivityCell", bundle: nil), forCellReuseIdentifier: "ActivityCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAndLoadActivities()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // @TODO: Suspend listening?
    }
    
    deinit {
        self.cleanup()
    }

    func cleanup() {
        // @TODO: Implement cleanup:
        dataManager.cleanup()
    }

    func endEditing() {
        self.view.endEditing(false)
    }

    // MARK:- Refresh Control for the TableView:
    func configureRefreshControl () {
        // Add the refresh control to your UIScrollView object.
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    func startRefreshIndicator() {
        tableView.refreshControl?.beginRefreshing()
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
    // It then asks the data accessor for them, which will give back the
    // actual activities we're permitted to use:
    func updateWantedActivities(with ids: [[ActivityId]], dataAccessor: DataAccessor = DataAccessor.instance) {
        self.dataManager.updateWantedActivities(with: ids)
    }

    // MARK:- Table view data source
    func updateActivityInSection(activity: Activity, section: Int) {
        if let path = dataSource.updateActivityInSection(activity: activity, section: section) {
            tableView.reloadRows(at: [path], with: .fade)
        }
    }
    
    func onNewActivities(newActivities: [[Activity]]) {
        dataSource.setActivities(newActivities)
        tableView.reloadData()
    }
    
    func removeActivityInSection(id: ActivityId, section: Int) {
        if let path = dataSource.removeActivityInSection(id: id, section: section) {
            tableView.deleteRows(at: [path], with: .fade)
        }
    }

    func onOperationsFinished() {
        tableView.refreshControl?.endRefreshing()
    }

    // Mark:- Displaying view activity:
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? ActivityCell
        // @TODO: can we perform the seuge without the cell? E.g. for displaying
        // view activity programmatically from notifications.......
        self.performSegue(withIdentifier: "showActivityDetails", sender: cell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectedIndex = self.tableView.indexPath(for: sender as! UITableViewCell)
        if let path = selectedIndex {
            let activityId = dataSource.get(path).activityId
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
