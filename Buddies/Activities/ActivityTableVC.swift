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
    var activities = [Activity?]()
    var activityCancelers = [Canceler]()
    
    var users      = [UserId: User]()
    var userImages = [UserId: UIImage]()
    var userCancelers = [ActivityId: [Canceler]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 120
        
        loadData()
    }
    
    func loadUser(uid: UserId, forPosition index: IndexPath, dataAccessor: DataAccessor = DataAccessor.instance) {
        let canceler = dataAccessor.useUser(id: uid) { user in
            self.users[user.uid] = user
            self.loadUserImage(user: user, forPosition: index)
            self.tableView.reloadRows(at: [index], with: .automatic)
        }
        userCancelers[uid]?.append(canceler)
    }
    
    func loadUserImage(user: User, forPosition index: IndexPath, storageManager: StorageManager = StorageManager.shared) {
        if userImages[user.uid] != nil { return }
        
        storageManager.getImage(
            imageUrl: user.imageUrl,
            localFileName: user.uid) { image in
                self.userImages[user.uid] = image
                self.tableView.reloadRows(at: [index], with: .automatic)
        }
    }
    
    func loadData(dataAccessor: DataAccessor = DataAccessor.instance){
        let displayIds = getDisplayIds()
        activities = [Activity?](repeating: nil, count: displayIds.count)

        for (section, ids) in displayIds.enumerated() {
            for (row, id) in ids.enumerated(){
                //Index that these users and activity are bound to
                let indexPath = indexPathForActivity(row: row, section: section)
                
                let canceler = dataAccessor.useActivity(id: id) { activity in
                    self.userCancelers[activity.activityId]?.forEach() { $0() }
                    activity.members.forEach() { self.loadUser(uid: $0, forPosition: indexPath) }
                    
                    self.activities[row] = activity
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                activityCancelers.append(canceler)
            }
        }
    }
    
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "activityCell", for: indexPath) as! ActivityCell
    
        let activity = getActivity(at: indexPath)
    
        return format(cell: cell, using: activity, at: indexPath)
    }
    
    
    //MARK:- Override for custom ActivityViewVCs
    func format(cell: ActivityCell, using activity: Activity?, at indexPath: IndexPath) -> ActivityCell{
        
        cell.titleLabel.text = activity?.title
        cell.descriptionLabel.text = activity?.description
        cell.locationLabel.text = String(activity?.location.latitude ?? 0) + ", " + String(activity?.location.longitude ?? 0)
        
        //TODO: Handle this ambiguity
        let dateRange = DateInterval(start:  activity?.startTime.dateValue() ?? Date(),
                                     end: activity?.endTime.dateValue() ?? Date())
        
        cell.dateLabel.text = dateRange.rangePhrase(relativeTo: Date())
        
        let activityUserImages = activity?.members.compactMap { userImages[$0] } ?? []
        
        zip(cell.memberPics, activityUserImages).forEach() { (btn, img) in btn.setImage(img, for: .normal)
        }

        // hide "..." as needed
        if activity?.members.count ?? 0 <= 3{
            cell.extraPicturesLabel.isHidden = true
        } else {
            cell.extraPicturesLabel.isHidden = false
        }
        
        return cell
    }
    
    func getActivity(at indexPath: IndexPath) -> Activity? {
        return activities[indexPath.row]
    }
    
    //Nested array, each subarray is for a section
    func getDisplayIds() -> [[ActivityId]] {
        return [["EgGiWaHiEKWYnaGW6cR3"]]
    }
    
    func indexPathForActivity(row: Int, section: Int) -> IndexPath {
        return IndexPath(row: row, section: section)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
}

