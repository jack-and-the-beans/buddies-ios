//
//  CreateActivityVC.swift
//  Buddies
//
//  Created by Grant Yurisic on 2/6/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

class CreateActivityVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            titleField.becomeFirstResponder()
        }
        else if indexPath.section == 1
        {
            locationField.becomeFirstResponder()
        }
    }
    
    
    @IBOutlet weak var titleField: UITextField!
    
    @IBOutlet weak var locationField: UITextField!
    
    var _dismissHook: (() -> Void)?
    
    @IBAction func cancelCreateActivity(_ segue: UIStoryboardSegue) {
         dismiss(animated: true, completion: _dismissHook)
    }
    
    @IBAction func finishCreateActivity(_ segue: UIStoryboardSegue) {
             dismiss(animated: true, completion: _dismissHook)
    }


}
