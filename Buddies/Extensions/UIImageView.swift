//
//  UIImageView.swift
//  Buddies
//
//  Created by Noah Allen on 2/21/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

extension UIImageView {
    func makeCircle () {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
}
