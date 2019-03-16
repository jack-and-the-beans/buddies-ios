//
//  BuddiesStoryboard.swift
//  Buddies
//
//  Created by Jake Thurman on 1/30/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit

enum BuddiesStoryboard : String {
    case Login = "Login"
    case Main = "Main"
    case Topics = "Topics"
    case CreateActivity = "CreateActivity"
    case LaunchScreen = "LaunchScreen"
    case Profile = "Profile"
    case Discover = "Discover"
    case ViewActivity = "ViewActivity"
        
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    func viewController<T : UIViewController>() -> T {
        guard let scene = instance.instantiateInitialViewController() as? T else {
            fatalError("No Initial ViewController for \(self.rawValue) Storyboard.")
        }
        
        return scene
    }
    
    func viewController<T : UIViewController>(withID id: String) -> T {
        guard let scene = instance.instantiateViewController(withIdentifier: id) as? T else {
            fatalError("No Initial ViewController for \(self.rawValue) Storyboard.")
        }
        
        return scene
    }
    
    func goTo(completion: (() -> Void)? = nil) {
        UIApplication.setRootView(viewController(), completion: completion)
    }
}
