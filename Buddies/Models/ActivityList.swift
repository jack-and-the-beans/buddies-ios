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
    // MARK: - Required TableView Methods for Data Source:
    func numberOfSections(in tableView: UITableView) -> Int {
        return activities.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (activities.flatMap { $0 }).count == 0 {
            tableView.setEmptyMessage("No results")
        } else {
            tableView.clearBackground()
        }
        return activities[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
        let activity = get(indexPath)
        // @TODO: use user information from activity:
        cell.format(using: activity, userImages: [])
        return cell
    }
    
    // MARK: - Methods for interacting with the data source:
    fileprivate var activities = [[Activity]]()

    func get(_ indexPath: IndexPath) -> Activity {
        // @TODO: return nil for outside of bounds
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

    func removeActivities(matching ids: [[String]]) -> [IndexPath] {
        let paths = getIndexPaths(of: ids)
        paths.forEach { activities[$0.section].remove(at: $0.row) }
        return paths
    }
    
    func updateActivities(_ activities: [[Activity]]) -> [IndexPath] {
        let paths = updateAndGetIndexPaths(of: activities)
        return paths
    }

    // Returns the index paths of the matching IDs:
    fileprivate func getIndexPaths(of activityIds: [[ActivityId]]) -> [IndexPath] {
        var result = [IndexPath]()
        for (section, ids) in activityIds.enumerated() {
            for id in ids {
                // We want to do something on the element at index
                let index = activities[section].firstIndex { $0.activityId == id }
                if let index = index {
                    let indexPath = IndexPath(row: index, section: section)
                    result.append(indexPath)
                }
            }
        }
        // Sort results with highest sections first, then highest rows first.
        return result.sorted {
            if ($0.section == $1.section) {
                return $0.row > $1.row
            }
            return $0.section > $1.section
        }
    }
    
    // Updates the given activities and returns their index paths:
    fileprivate func updateAndGetIndexPaths(of activityUpdates: [[Activity]]) -> [IndexPath] {
        var result = [IndexPath]()
        for (section, activityList) in activityUpdates.enumerated() {
            for activity in activityList {
                // We want to do something on the element at index
                let index = activities[section].firstIndex { $0.activityId == activity.activityId }
                if let index = index {
                    activities[section][index] = activity
                    let indexPath = IndexPath(row: index, section: section)
                    result.append(indexPath)
                }
            }
        }
        return result
    }
}
