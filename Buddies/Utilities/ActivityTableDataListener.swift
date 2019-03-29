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
    func onActivityUpdate(updatedActivity: Activity)
    func onNewActivities(newActivities: [[Activity]])
    func onRemoveActivity(activityId: ActivityId)
    func onOperationsFinished()
}

class ActivityTableDataListener {
    let dataAccessor = DataAccessor.instance
    var delegate: ActivityTableDataDelegate? = nil

    var cancelers = [Canceler]()

    // A list of the activities we want to get:
    var wantedActivities = [[ActivityId]]()
    // A list of the activities for which we've
    // handled the initial setup. The boolean
    // denotes whether or not the activity DNE.
    var handledActivities = [ActivityId : Bool]()

    // Returns the nested array flattened to a single list, in order.
    fileprivate func getStringsInOrder(_ ids: [[String]]) -> [String] {
        var allids = ids.flatMap { $0 }
        allids.sort()
        return allids
    }
    
    func updateWantedActivities(with ids: [[ActivityId]]) {
        let orderedNewIds = getStringsInOrder(ids)
        // Checks to see if the arrays are different. If they are the same,
        // cancel the operation. Otherwise, continue getting the activities.
        if (orderedNewIds == getStringsInOrder(wantedActivities)) {
            delegate?.onOperationsFinished()
            return
        }

        self.wantedActivities = ids
        self.handledActivities = [:]
        self.cleanup()

        let newActivities = [[Activity]]()
        
        self.cancelers = ids.enumerated().flatMap { i, idList in
            return idList.enumerated().map { j, id in
                return dataAccessor.useActivity(id: id) { activity in
                    if (self.handledActivities[id] == nil && activity != nil) {
                        // DNE yet but we have the activity
                        // @TODO: save the activity
                        self.handledActivities[id] = true
                        if (self.handledActivities.count == orderedNewIds.count) {
                            // Now, all activities have been handled
                            self.delegate?.onNewActivities(newActivities: newActivities)
                        }
                    } else if self.handledActivities[id] == nil {
                        // DNE yet, but the activity is nil
                        self.handledActivities[id] = false
                    } else if let activity = activity {
                        // Already exists, and we have an activity
                        self.delegate?.onActivityUpdate(updatedActivity: activity)
                        self.handledActivities[id] = true
                    } else {
                        // Already exists, but the activity is now nil
                        self.delegate?.onRemoveActivity(activityId: id)
                        self.handledActivities[id] = false
                    }
                }
            }
        }
    }
    
    func cleanup() {
        self.cancelers.forEach { $0() }
    }
}
