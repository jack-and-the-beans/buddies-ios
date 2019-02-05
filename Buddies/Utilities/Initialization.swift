//
//  Initialization.swift
//  Buddies
//
//  Created by Luke Meier on 1/31/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import UIKit


class AppContent {
    static func setup(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.topicCollection.topics = []
        appDelegate.topicCollection.loadTopics()
    }
}
