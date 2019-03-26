//
//  UITableViewExt.swift
//  Buddies
//
//  Created by Luke Meier on 3/26/19.
//     from https://stackoverflow.com/questions/15746745/handling-an-empty-uitableview-print-a-friendly-message
//
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//
import UIKit

extension UITableView {
    
    func setEmptyMessage(_ message: String, font: UIFont = UIFont.systemFont(ofSize: 15)) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = font
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
        self.separatorStyle = .none;
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

extension UICollectionView {
    
    func setEmptyMessage(_ message: String, font: UIFont = UIFont.systemFont(ofSize: 15)) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = font
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

//use:
//
//
//override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    if things.count == 0 {
//        self.tableView.setEmptyMessage("My Message")
//    } else {
//        self.tableView.restore()
//    }
//
//    return things.count
//}
