//
//  ActivityTableVC.swift
//  Buddies
//
//  Created by Luke Meier on 2/8/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import Firebase

class ActivityTableVC: UITableViewController {
    let search = AlgoliaSearch()
    
    var activities = [[Activity?]]()
    var activityCancelers = [Canceler]()
    
    var users      = [UserId: User]()
    var userImages = [UserId: UIImage]()
    var userCancelers = [ActivityId: [Canceler]]()
    
    //Doubly nested array of Activity Ids.
    //Each array is a section of the table view
    var displayIds = [[ActivityId]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 110
        fetchAndLoadActivities()
    }
    
    deinit {
        cleanup()
    }
    
    func loadUser(uid: UserId,
                  dataAccessor: DataAccessor = DataAccessor.instance,
                  storageManager: StorageManager = StorageManager.shared,
                  onLoaded: (()->Void)?) {
        
        let canceler = dataAccessor.useUser(id: uid) { user in
            self.users[user.uid] = user
            self.loadUserImage(user: user, storageManager: storageManager, onLoaded: onLoaded)
            onLoaded?()
        }
        userCancelers[uid]?.append(canceler)
    }
    
    func loadUserImage(user: User,
                       storageManager: StorageManager = StorageManager.shared,
                       onLoaded: (()->Void)?) {
        
        if userImages[user.uid] != nil { return }
        
        storageManager.getImage(
            imageUrl: user.imageUrl,
            localFileName: user.uid) { image in
                self.userImages[user.uid] = image
                onLoaded?()
        }
    }
    
    func loadActivity(_ id: ActivityId,
                      at indexPath: IndexPath,
                      dataAccessor: DataAccessor = DataAccessor.instance,
                      storageManager: StorageManager = StorageManager.shared,
                      onLoaded: (()->Void)?){
        
        let canceler = dataAccessor.useActivity(id: id) { activity in
            self.userCancelers[activity.activityId]?.forEach() { $0() }
            
            activity.members.forEach() { uid in
                self.loadUser(uid: uid, storageManager: storageManager, onLoaded: onLoaded)
            }
            
            self.activities[indexPath.section][indexPath.row] = activity
            onLoaded?()
        }
        activityCancelers.append(canceler)

    }
    
    func loadData(for displayIds: [[String]],
                  dataAccessor: DataAccessor = DataAccessor.instance,
                  storageManager: StorageManager = StorageManager.shared){
        
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
        
        cell.dateLabel.text = dateRange.rangePhrase(relativeTo: Date())
        
        let activityUserImages = activity.members.compactMap { userImages[$0] }
        
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
    
    // "abstract"
    // Must call loadData() once displayIds is set
    func fetchAndLoadActivities(){}

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectedIndex = self.tableView.indexPath(for: sender as! UITableViewCell)
        if let nav = segue.destination as? UINavigationController,
            let path = selectedIndex,
            let activityController = nav.viewControllers[0] as? ViewActivityController{
            let tappedActivity = getActivity(at: path)
            activityController.loadWith(tappedActivity?.activityId)
        }
    }
}

