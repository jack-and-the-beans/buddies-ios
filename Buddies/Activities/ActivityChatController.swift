//
//  ActivityChatController.swift
//  Buddies
//
//  Created by Noah Allen on 2/19/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

class ActivityChatController: UIView {
    private var showActivityDetails = false
    private var activity: Activity?
    private var memberStatus: MemberStatus?

    @IBOutlet weak var chatAreaView: UIView!
    @IBOutlet weak var statusLabel: UILabel!

    private var hasMounted = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hasMounted = true
        render()
    }
    
    func refreshData(with activity: Activity?, memberStatus: MemberStatus?) {
        self.activity = activity
        self.memberStatus = memberStatus
        render()
    }
    
    func render() {
        guard hasMounted, let _ = self.activity, let status = self.memberStatus else { return }
        self.statusLabel?.text = status == .owner ? "Owner" : "Member"
    }
}
