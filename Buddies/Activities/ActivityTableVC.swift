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
    var displayIds = [ActivityId]()
    var activities = [ActivityComponent]()
    var users      = [UserId: UserComponent]()
    
    var handleUserLoaded: ((User) -> Void)!
    var handleImageLoaded: ((UIImage) -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 120
        
        handleUserLoaded = { user in self.tableView.reloadData() }
        handleImageLoaded = { image in self.tableView.reloadData() }
        
        loadData()
    }
    
    func loadUser(uid: UserId) -> UserComponent?{
        if users[uid] == nil {
            users[uid] = UserComponent(uid: uid, userLoadedFn: handleUserLoaded, imageLoadedFn: handleImageLoaded)
        }
        return users[uid]
    
    }
    
    func loadData(){
        displayIds = getDisplayIds()
        activities = []

        for id in displayIds {
            let activity = ActivityComponent(uid: id) { activity in
                self.tableView.reloadData()
                activity.members.forEach() { let _ = self.loadUser(uid: $0) }
            }
            activities.append(activity)
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
        
        let activityUserImages = activity?.members.compactMap { users[$0]?.image } ?? []
        
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
        return activities[indexPath.row].activity
    }
    
    
    func getDisplayIds() -> [ActivityId] {
        return ["EgGiWaHiEKWYnaGW6cR3"]
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
}

