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
    // denotes whether or not the activity exists.
    var handledActivities = [ActivityId : Bool]()

    var didFinishSetup = false
    
    func updateWantedActivities(with ids: [[ActivityId]], dataAccessor: DataAccessor = DataAccessor.instance) {
        let orderedNewIds = getStringsInOrder(ids)
        // Checks to see if the arrays are different. If they are the same,
        // cancel the operation. Otherwise, continue getting the activities.
        if (orderedNewIds == getStringsInOrder(wantedActivities) && orderedNewIds.count > 0 ) {
            delegate?.onOperationsFinished()
            return
        }

        self.wantedActivities = ids
        self.handledActivities = [:]
        self.cleanup()
        self.didFinishSetup = false

        // Handle the case where the we're trying to get nothing:
        if (orderedNewIds.count == 0) {
            let emptyResult: [[Activity]] = ids.map { _ in [] }
            delegate?.onNewActivities(newActivities: emptyResult)
            delegate?.onOperationsFinished()
            return
        }

        var newActivities: [[Activity?]] = ids.map { $0.map { _ in nil } }
        
        self.cancelers = []
        self.cancelers += ids.enumerated().flatMap { i, idList in
            return idList.enumerated().map { j, id in
                return dataAccessor.useActivity(id: id) { activity in
                    if (self.handledActivities[id] == nil && activity != nil) {
                        // Going from not having the activity to having it
                        newActivities[i][j] = activity
                        self.handledActivities[id] = true
                    } else if self.handledActivities[id] == nil {
                        // DNE yet, but the activity is nil
                        self.handledActivities[id] = false
                    } else if let activity = activity {
                        // Update the activity in the table:
                        newActivities[i][j] = activity
                        // Already exists, and we have an activity
                        if (self.didFinishSetup) {
                            self.delegate?.updateActivityInSection(activity: activity, section: i)
                            self.delegate?.onOperationsFinished()
                        }
                        self.handledActivities[id] = true
                    } else {
                        // Set the activity in the table to nil:
                        newActivities[i][j] = nil
                        // Already exists, but the activity is now nil
                        if (self.didFinishSetup) {
                            self.delegate?.removeActivityInSection(id: id, section: i)
                            self.delegate?.onOperationsFinished()
                        }
                        self.handledActivities[id] = false
                    }
                    
                    // If we're done with setup, AND if we have handled all the
                    // activities, give them back!
                    if (self.handledActivities.count == orderedNewIds.count && !self.didFinishSetup) {
                        // Now, all activities have been handled
                        let trimedActivities = self.trimActivities(newActivities)
                        self.delegate?.onNewActivities(newActivities: trimedActivities)
                        self.didFinishSetup = true
                        self.delegate?.onOperationsFinished()
                    }
                    
                    guard let activity = activity else { return }
                    self.cancelers += [dataAccessor.useUsers(from: activity.members) { users in
                        activity.users = users
                        newActivities[i][j] = activity
                        if (self.didFinishSetup) {
                            self.delegate?.updateActivityInSection(activity: activity, section: i)
                        }
                    }]
                }
            }
        }
    }

    // Removes the nils from the given array:
    func trimActivities(_ activities: [[Activity?]]) -> [[Activity]] {
        return activities.map { $0.compactMap { $0 } }
    }

    // Returns the nested array flattened to a single list, in order.
    func getStringsInOrder(_ ids: [[String]]) -> [String] {
        var allids = ids.flatMap { $0 }
        allids.sort()
        return allids
    }

    func cleanup() {
        self.cancelers.forEach { $0() }
    }
}
