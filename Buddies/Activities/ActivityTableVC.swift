//
//  ActivityTableVC.swift
//  Buddies
//
//  Created by Luke Meier on 2/8/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import Firebase

class ActivityTableVC: UITableViewController, FilterSearchBarDelegate {
    //MARK:- User and activity data and data management
    var activities = [[Activity?]]()
    var activityCancelers = [Canceler]()
    
    var users      = [UserId: User]()
    var userCancelers = [ActivityId: [Canceler]]()
    
    //Doubly nested array of Activity Ids.
    //Each array is a section of the table view
    var displayIds = [[ActivityId]]()
    
    //MARK:- Search API
    //Should only be changed by unit tests
    var api = AlgoliaSearch()
    
    var lastSearchParam: SearchParams! = (nil, Date(), Date(), 0)
    
    var fab: FAB!

    
    //MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 110
        
        // We need to store a local so that the
        //  instance isn't deallocated along with
        //  the event handler!
        fab = FAB(for: self)
        fab.renderCreateActivityFab()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAndLoadActivities(for: lastSearchParam)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cleanup()
    }

    // Must get a list of the appropiate topics for the view
    func getTopics() -> [String] {return []}
    
    func endEditing() {
        self.view.endEditing(false)
    }
    
    //MARK:- Manage queries and query changes
    func fetchAndLoadActivities(for params: SearchParams? = nil){
        lastSearchParam = params
        // Must call loadData() with activity ids in order to render anything
    }
    
    func loadAlgoliaResults(activities: [ActivityId], from params: SearchParams?, err: Error?){
        // Cancel if we've made a new request #NoRaceConditions
        if params == nil || self.searchParamsChanged(from: params!) { return }
        
        // Handle errors
        if let error = err { print(error) }
    
        // Load new data
        self.loadData(for: [activities])
    }
    
    func searchParamsChanged(from params: SearchParams) -> Bool {
        return lastSearchParam == nil || lastSearchParam! != params
    }
    
    
    //MARK: - Load user from DataAccessor
    func loadUser(uid: UserId,
                  dataAccessor: DataAccessor = DataAccessor.instance,
                  onLoaded: (()->Void)?) {
        
        let canceler = dataAccessor.useUser(id: uid) { user in
            if let user = user {
                self.users[user.uid] = user
            } else if self.users[uid] != nil {
                self.users.removeValue(forKey: uid)
            }
            onLoaded?()
        }
        if userCancelers[uid] == nil { userCancelers[uid] = [] }
        userCancelers[uid]?.append(canceler)
    }
    
    func loadActivity(_ id: ActivityId,
                      at indexPath: IndexPath,
                      dataAccessor: DataAccessor = DataAccessor.instance,
                      onLoaded: (()->Void)?){
        
        let canceler = dataAccessor.useActivity(id: id) { activity in
            self.userCancelers[id]?.forEach() { $0() }

            if let activity = activity {
                activity.members.forEach() { uid in
                    self.loadUser(uid: uid, onLoaded: onLoaded)
                }
            }

            self.activities[indexPath.section][indexPath.row] = activity
            
            onLoaded?()
        }
        activityCancelers.append(canceler)

    }
    
    func loadData(for displayIds: [[String]], dataAccessor: DataAccessor = DataAccessor.instance){
        //Each time we load data, get rid of old listeners
        cleanup()
        
        self.displayIds = displayIds

        //Create an nil-filled nested array of activities
        activities = displayIds.map { $0.map { _ in nil } }
        
        //Reload here so that we have the right number of empty cells
        //Since we are loading async and data size,
        // we reload here to avoid inconsistency errors
        tableView.reloadData()

        for (section, ids) in displayIds.enumerated() {
            for (row, id) in ids.enumerated(){
                //Index that these users and activity are bound to
                let indexPath = IndexPath(row: row, section: section)
                loadActivity(id, at: indexPath) {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                
            }
        }
    }
    
    func cleanup(){
        activityCancelers.forEach() { $0() }
        activityCancelers = []
        for cancelers in userCancelers.values {
            cancelers.forEach { $0() }
        }
        userCancelers = [:]
    }
    
   
    //MARK:- Table view rendering
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! ActivityCell
    
        if let activity = getActivity(at: indexPath) {
            return format(cell: cell, using: activity, at: indexPath)
        } else {
            cell.isHidden = true
            return cell
        }
    }
    
    func format(cell: ActivityCell, using activity: Activity, at indexPath: IndexPath) -> ActivityCell{
        
        cell.titleLabel.text = activity.title
        cell.descriptionLabel.text = activity.description
        cell.locationLabel.text = activity.locationText
        let dateRange = DateInterval(start: activity.startTime.dateValue(),
                                     end: activity.endTime.dateValue())
    
        
        let pixelsPerChar: CGFloat = 10.0
        
        let charsFitInCell = Int(cell.frame.width/pixelsPerChar)
        
        let locStrLength = max(15, charsFitInCell - activity.title.count)
        
        let locStr = dateRange.rangePhrase(relativeTo: Date(), tryShorteningIfLongerThan: locStrLength)
        
        cell.dateLabel.text = locStr.capitalized

        let activityUserImages = activity.members.compactMap { users[$0]?.image }
        
        zip(cell.memberPics, activityUserImages).forEach() { (btn, img) in btn.setImage(img, for: .normal)
        }
        

        // hide "..." as needed
        if activity.members.count <= 3{
            cell.extraPicturesLabel.isHidden = true
        } else {
            cell.extraPicturesLabel.isHidden = false
        }
        
        return cell
    }
    
    func getActivity(at indexPath: IndexPath) -> Activity? {
        return activities[indexPath.section][indexPath.row]
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return displayIds.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayIds[section].count
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectedIndex = self.tableView.indexPath(for: sender as! UITableViewCell)
        if let activityController = segue.destination as? ViewActivityController,
            let path = selectedIndex {
            let tappedActivity = getActivity(at: path)
            activityController.loadWith(tappedActivity?.activityId)
        }
    }
}

