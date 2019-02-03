//
//  Testing.swift
//  BuddiesTests
//
//  Created by Jake Thurman on 2/2/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

class Testing {
    // Taken from: https://stackoverflow.com/questions/26667009/get-top-most-uiviewcontroller
    class func getTopViewController(of controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return getTopViewController(of: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return getTopViewController(of: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return getTopViewController(of: presented)
        }
        return controller
    }
}
