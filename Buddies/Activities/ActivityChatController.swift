//
//  ActivityChatController.swift
//  Buddies
//
//  Created by Noah Allen on 2/19/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

class ActivityChatController: UIView {
    @IBOutlet weak var chatAreaView: UIView!
    @IBOutlet weak var statusLabel: UILabel!

    // Local data for rendering:
    private var activity: Activity?
    private var memberStatus: MemberStatus?
    
    // Call this to re-render with new data:
    func render(with activity: Activity?, memberStatus: MemberStatus?) {
        self.activity = activity
        self.memberStatus = memberStatus
        self.statusLabel?.text = memberStatus == .owner ? "You are this activity's owner." : "You are a member of this activity."
    }
}
