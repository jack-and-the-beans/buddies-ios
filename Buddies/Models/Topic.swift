//
//  TopicCollection.swift
//  Buddies
//
//  Created by Luke Meier on 1/31/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import Firebase

class Topic {
    let id: String
    var name: String
    var image: UIImage?
  
    init(id: String, name: String, image: UIImage?) {
        self.id = id
        self.name = name
        self.image = image
    }
}
