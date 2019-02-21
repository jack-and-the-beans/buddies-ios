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

    @IBOutlet weak var topActivityView: UIView!
    @IBOutlet weak var statusLabel: UILabel!

    @IBAction func onShowDetailsTap(_ sender: Any) {
        self.showActivityDetails = !self.showActivityDetails
        render()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        render()
    }
    
    func refreshData(with activity: Activity?, memberStatus: MemberStatus?) {
        self.activity = activity
        self.memberStatus = memberStatus
        render()
    }
    
    func render() {
        guard let _ = self.activity, let status = self.memberStatus else { return }
        if (showActivityDetails) {
            self.topActivityView.bindFrameToSuperviewBounds()
        }
        self.statusLabel?.text = status == .owner ? "Owner" : "Member"
    }

    func animateView() {
        UIView.animate(withDuration: 1.5) {
        }
    }
}
