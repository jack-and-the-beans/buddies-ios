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
    var selected: Bool
  
    init(id: String, name: String, image: UIImage?, selected: Bool = false) {
        self.id = id
        self.name = name
        self.image = image
        self.selected = selected
    }
    
    convenience init?(id: String, data: [String: Any]?){
        guard let name = data?["name"] as? String else {
                return nil
        }
        self.init(id: id, name: name, image: nil)
        
    }
}
