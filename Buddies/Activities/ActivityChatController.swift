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
    @IBOutlet weak var topActivityView: UIView!
    @IBOutlet weak var statusLabel: UILabel!

    private var hasMounted = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        let tap = UILongPressGestureRecognizer(target: self, action: #selector(animateView))
//        tap.minimumPressDuration = 0
//        topActivityView.addGestureRecognizer(tap)
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
        if (showActivityDetails) {
        }
        self.statusLabel?.text = status == .owner ? "Owner" : "Member"
    }

//    @objc func animateView(gesture: UITapGestureRecognizer) {
//        if (gesture.state == .ended) {
//            if let description = self.descriptionView {
//                self.topActivityView.addSubview(description)
//            }
//            self.showActivityDetails = !self.showActivityDetails
//            let viewHeight = showActivityDetails ? chatAreaView.frame.height : 80
//            let viewWidth = chatAreaView.frame.width
//            UIView.animate(withDuration: 0.2) {
//                self.topActivityView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
//            }
//        }
//    }
//    
//    func updateDescriptionView(with view: UIView) {
//        self.descriptionView = view
//    }
}
