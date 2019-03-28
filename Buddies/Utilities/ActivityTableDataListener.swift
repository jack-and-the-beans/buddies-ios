//
//  ActivityTableDataListener.swift
//  Buddies
//
//  Created by Noah Allen on 3/28/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

// ActivityTableVC, for example, implements these
// in order to handle live updates from the data
// source.
protocol ActivityTableDataDelegate {
    func onActivityUpdate(updatedActivities: [[Activity]])
    func onNewActivities(newActivities: [[Activity]])
    func onRemoveActivities(activityIds: [[ActivityId]])
    func onOperationsFinished()
}

class ActivityTableDataListener {
    var wantedActivities = [[ActivityId]]()
    var delegate: ActivityTableDataDelegate? = nil

    // Returns the nested array flattened to a single list, in order.
    fileprivate func getStringsInOrder(_ ids: [[String]]) {
        var allids = ids.flatMap { $0 }
        return allids.sort()
    }
    
    func updateWantedActivities(with ids: [[ActivityId]]) {
        // Checks to see if the arrays are different. If they are the same,
        // cancel the operation. Otherwise, continue getting the activities.
        guard (getStringsInOrder(ids) != getStringsInOrder(wantedActivities)) else {
            delegate?.onOperationsFinished()
            return
        }
        self.wantedActivities = ids
        // @TODO: Ask firebase for dem activities.
    }
    
    func cleanup() {
        // @TODO: Implement cleanup
    }
    
}
