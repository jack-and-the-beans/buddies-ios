//
//  ActivityList.swift
//  Buddies
//
//  Created by Noah Allen on 3/28/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import UIKit

class ActivityList: NSObject, UITableViewDataSource {
    var sectionHeaders: [String] = []

    // MARK: - Required TableView Methods for Data Source:
    func numberOfSections(in tableView: UITableView) -> Int {
        return activities.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ( hasNoActivities() ) {
            tableView.setEmptyMessage("No results")
        } else {
            tableView.clearBackground()
        }
        return activities[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
        let activity = get(indexPath)
        cell.format(using: activity)
        return cell
    }
    
    // MARK: - Methods for interacting with the data source:
    fileprivate var activities = [[Activity]]()

    func hasNoActivities() -> Bool {
        return activities.flatMap { $0 }.count == 0
    }

    func get(_ indexPath: IndexPath) -> Activity {
        return activities[indexPath.section][indexPath.row]
    }
    
    func numSections () -> Int {
        return activities.count
    }

    func numRows(in section: Int) -> Int {
        return activities[section].count
    }

    func setActivities(_ activities: [[Activity]]) {
        self.activities = activities
    }

    func removeActivityInSection(id: ActivityId, section: Int) -> IndexPath? {
        if let path = getIndexPath(of: id, in: section) {
            activities[path.section].remove(at: path.row)
            return path
        }
        return nil
    }
    
    func updateActivityInSection(activity: Activity, section: Int) -> IndexPath? {
        return updateAndGetIndexPath(of: activity, at: section)
    }

    func setSectionHeaders(_ headers: [String]) {
        self.sectionHeaders = headers
    }

    // If we don't handle section headers in this class, they won't display whatsoever:
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < sectionHeaders.count {
            return sectionHeaders[section]
        }
        return nil
    }

    // Returns the index paths of the matching ID:
    fileprivate func getIndexPath(of activityId: ActivityId, in section: Int) -> IndexPath? {
        let index = activities[section].firstIndex { $0.activityId == activityId }
        if let index = index {
            return IndexPath(row: index, section: section)
        } else {
            return nil
        }
    }
    
    // Updates the given activities and returns their index paths:
    fileprivate func updateAndGetIndexPath(of activity: Activity, at section: Int) -> IndexPath? {
        let index = activities[section].firstIndex { $0.activityId == activity.activityId }
        if let index = index {
            activities[section][index] = activity
            return IndexPath(row: index, section: section)
        } else {
            return nil
        }
    }
}
