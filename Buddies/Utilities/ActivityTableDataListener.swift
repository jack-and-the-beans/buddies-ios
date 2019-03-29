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
    func updateActivityInSection(activity: Activity, section: Int)
    func onNewActivities(newActivities: [[Activity]])
    func removeActivityInSection(id: ActivityId, section: Int)
    func onOperationsFinished()
}

class ActivityTableDataListener {
    var delegate: ActivityTableDataDelegate? = nil

    var cancelers = [Canceler]()

    // A list of the activities we want to get:
    var wantedActivities = [[ActivityId]]()
    // A list of the activities for which we've
    // handled the initial setup. The boolean
    // denotes whether or not the activity DNE.
    var handledActivities = [ActivityId : Bool]()

    var didFinishSetup = false

    // Returns the nested array flattened to a single list, in order.
    fileprivate func getStringsInOrder(_ ids: [[String]]) -> [String] {
        var allids = ids.flatMap { $0 }
        allids.sort()
        return allids
    }
    
    func updateWantedActivities(with ids: [[ActivityId]], dataAccessor: DataAccessor = DataAccessor.instance) {
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
        self.didFinishSetup = false

        var newActivities: [[Activity?]] = ids.map { $0.map { _ in nil } }
        
        self.cancelers = ids.enumerated().flatMap { i, idList in
            return idList.enumerated().map { j, id in
                return dataAccessor.useActivity(id: id) { activity in
                    if (self.handledActivities[id] == nil && activity != nil) {
                        // DNE yet but we have the activity
                        newActivities[i][j] = activity
                        self.handledActivities[id] = true
                        if (self.handledActivities.count == orderedNewIds.count) {
                            // Now, all activities have been handled
                            let trimedActivities = self.trimActivities(newActivities)
                            self.delegate?.onNewActivities(newActivities: trimedActivities)
                            self.didFinishSetup = true
                            self.delegate?.onOperationsFinished()
                        }
                    } else if self.handledActivities[id] == nil {
                        // DNE yet, but the activity is nil
                        self.handledActivities[id] = false
                    } else if let activity = activity {
                        // Update the activity in the big list
                        newActivities[i][j] = activity
                        // Already exists, and we have an activity
                        if (self.didFinishSetup) {
                            self.delegate?.updateActivityInSection(activity: activity, section: i)
                        }
                        self.handledActivities[id] = true
                    } else {
                        // Set the activity in the list to nil:
                        newActivities[i][j] = nil
                        // Already exists, but the activity is now nil
                        if (self.didFinishSetup) {
                            self.delegate?.removeActivityInSection(id: id, section: i)
                        }
                        self.handledActivities[id] = false
                    }
                }
            }
        }
    }

    // Removes the nils from the given array:
    func trimActivities(_ activities: [[Activity?]]) -> [[Activity]] {
        return activities.map { $0.compactMap { $0 } }
    }

    func cleanup() {
        self.cancelers.forEach { $0() }
    }
}
