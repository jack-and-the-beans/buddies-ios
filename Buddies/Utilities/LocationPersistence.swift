//
//  LocationPersistence.swift
//  Buddies
//
//  Created by Jake Thurman on 3/13/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import CoreLocation
import FirebaseFirestore

class LocationPersistence : NSObject, CLLocationManagerDelegate {
    static let instance = LocationPersistence()

    let manager = CLLocationManager()
    var cancelUserListener: Canceler!
    var user: LoggedInUser?
    
    deinit {
        cancelUserListener()
    }
    
    init(dataAccessor: DataAccessor = DataAccessor.instance) {
        super.init()
        
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        
        cancelUserListener = dataAccessor.useLoggedInUser { user in
            self.user = user
            
            // On user change, record where we are imediately
            if let loc = self.manager.location {
                user?.location = GeoPoint(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
            }
        }
    }
    
    func makeSureWeHaveLocationAccess(from vc: UIViewController) {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            let alert = UIAlertController(title: "Location Services disabled", message: "Please enable Location Services for Buddies in Settings", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            vc.present(alert, animated: true, completion: nil)
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            // Write new location to firebase
            //  this will automatically propigate it to 
            user?.location = GeoPoint(
                latitude: loc.coordinate.latitude,
                longitude: loc.coordinate.longitude)
        }
    }//func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!)

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LOCATION ERROR:\n---------------\n\n\(error)")
    }
}
