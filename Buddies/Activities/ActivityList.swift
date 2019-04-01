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
        return activities[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
        let activity = self[activityAt: indexPath]
        cell.format(using: activity)
        return cell
    }
    
    // MARK: - Methods for interacting with the data source:
    var activities = [[Activity]]()

    func hasNoActivities() -> Bool {
        return activities.flatMap { $0 }.count == 0
    }

    subscript(activityAt indexPath: IndexPath) -> Activity {
        return activities[indexPath.section][indexPath.row]
    }
    

    func setActivities(_ activities: [[Activity]]) -> [IndexPath]? {
        // Get sets of the current and existing activity IDs:
        let currentIds = Set(self.activities.flatMap { $0.map { $0.activityId } })
        let newIds = Set(activities.flatMap { $0.map { $0.activityId } })
        
        // Use set operations to figure out what the added and removed activities are:
        let addedActivities = newIds.subtracting( currentIds )
        let removedActivities = currentIds.subtracting( newIds )
        
        // In this case, we have only removed an activity; we have not added any.
        // As a result, we can make the animation more clean by just deleting
        // the rows at the specified activities.
        if (removedActivities.count > 0 && addedActivities.count == 0) {
            let removedIndices = removedActivities.compactMap { getIndexPath(of: $0 ) }
            // Note: only set activities AFTER we have the indexes of the deleted ones:
            self.activities = activities
            return removedIndices
        }
        self.activities = activities
        return nil
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

    // Returns the index path of the matching ID:
    func getIndexPath(of activityId: ActivityId, in section: Int) -> IndexPath? {
        if (section >= activities.count) {
            return nil
        }
        let index = activities[section].firstIndex { $0.activityId == activityId }
        if let index = index {
            return IndexPath(row: index, section: section)
        } else {
            return nil
        }
    }

    // Gets the index path of an activityID no matter its section:
    func getIndexPath(of activityId: ActivityId) -> IndexPath? {
        for (i, section) in self.activities.enumerated() {
            for (j, activity) in section.enumerated() {
                if activity.activityId == activityId {
                    return IndexPath(row: j, section: i)
                }
            }
        }
        return nil
    }

    // Updates the given activity and returns its index path:
    func updateAndGetIndexPath(of activity: Activity, at section: Int) -> IndexPath? {
        if (section >= activities.count) {
            return nil
        }
        let index = activities[section].firstIndex { $0.activityId == activity.activityId }
        if let index = index {
            activities[section][index] = activity
            return IndexPath(row: index, section: section)
        } else {
            return nil
        }
    }
}
