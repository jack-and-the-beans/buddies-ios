//
//  CreateActivityVC.swift
//  Buddies
//
//  Created by Grant Yurisic on 2/6/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import UIKit
import MapKit
import Firebase

//https://stackoverflow.com/questions/33380711/how-to-implement-auto-complete-for-address-using-apple-map-kit
//https://www.thorntech.com/2016/01/how-to-search-for-location-using-apples-mapkit/
//https://stackoverflow.com/questions/39946100/search-for-address-using-swift
class CreateActivityVC: UITableViewController, UITextViewDelegate, UITextFieldDelegate{
    
    //MARK: - Variables/setup
    var chosenLocation = CLLocationCoordinate2D()
    var locationManager = CLLocationManager()
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    var region : MKCoordinateRegion!
    
    var _dismissHook: (() -> Void)?

    var topicCollection: TopicCollection?
    var selectedTopics = [Topic]()
    
    @IBOutlet weak var locationField: SearchTextField!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var titleField: UITextField!
    
    
    @IBAction func cancelCreateActivity(_ segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: _dismissHook)
    }
    
    @IBAction func finishCreateActivity(_ segue: UIStoryboardSegue) {
        
        guard let title = titleField.text else {return}
        guard let description = descriptionTextView.text else {return}
        saveActivityToFirestore(title: title, description: description, location: GeoPoint(latitude: chosenLocation.latitude, longitude: chosenLocation.longitude))
        dismiss(animated: true, completion: _dismissHook)
    }
    
    //MARK: - Editing
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = UIColor.lightGray
        }
    }
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchCompleter.queryFragment = "warm up"
        
        
        descriptionTextView.delegate = self
        descriptionTextView.textColor = UIColor.lightGray
        self.setupHideKeyboardOnTap()
        configureSearchTextField()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()

        searchCompleter.delegate = self
        region = MKCoordinateRegion(
            center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(),
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        
        
        searchCompleter.region = region
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //MARK: - Setup for Pick topics
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        topicCollection = appDelegate.topicCollection
    }
    
    //MARK: - Topics
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nav = segue.destination as? UINavigationController,
            let topicPicker = nav.viewControllers[0] as? TopicsVC else { return }
        topicPicker.topicCollection = topicCollection
        print("Trying to pass \(selectedTopics.map { $0.name })")
        topicPicker.selectedTopics = selectedTopics
        
    }
    
    @IBAction func unwindPickTopics(sender: UIStoryboardSegue) {
        if let source = sender.source as? TopicsVC {
            selectedTopics = source.selectedTopics
            print("Selected \(selectedTopics.map { $0.name })")
        }
    }
    
    @IBAction func unwindCancelPickTopics(sender: UIStoryboardSegue) {
        
    }
    
    //MARK: - Firestore
    
    func saveActivityToFirestore(
        title: String = "Title",
        description: String = "Description",
        location: GeoPoint = GeoPoint(latitude: 0, longitude: 0),
        user: UserInfo? = Auth.auth().currentUser,
        collection: CollectionReference = Firestore.firestore().collection("activities"),
        startTime: Date = Date(),
        endTime: Date = Date(),
        topicIDs: [String] = []){
        
        guard let uid = user?.uid else {return}
        
        collection.addDocument(data: [
            "title": title,
            "owner_id": uid,
            "description" : description,
            "date_created": Date(),
            "location": location,
            "start_time": startTime,
            "end_time": endTime,
            "topic_ids": topicIDs,
            "members": [uid]
        ])
    }
    
    //MARK: - Location field
    func configureSearchTextField()
    {
        
        locationField.theme.cellHeight = 50
        locationField.maxNumberOfResults = 10
        locationField.maxResultsListHeight = 250
        locationField.minCharactersNumberToStartFiltering = 1
        locationField.comparisonOptions = [.caseInsensitive]
        locationField.theme.font = UIFont.systemFont(ofSize: 12)
        locationField.theme.bgColor = UIColor.white
        
        
        
        locationField.userStoppedTypingHandler = {
            if let query = self.locationField.text {
                if query.count > 1 {
                    
                    
                    if(self.searchCompleter.isSearching){
                        self.searchCompleter.cancel()
                    }
                    
                    self.searchCompleter.queryFragment = query
                    
                    // Show the loading indicator
                    self.locationField.showLoadingIndicator()
                    self.completerDidUpdateResults(completer: self.searchCompleter)
                    
                    var displayResults:[MapItemSearchResult] = []
                    
                    for item in self.searchResults {
                        let temp = MapItemSearchResult(title: item.title)
                        temp.subtitle = item.subtitle
                        temp.mapData = item
                        displayResults.append(temp)
                    }
                    
                    self.locationField.filterItems(displayResults)
                    self.locationField.stopLoadingIndicator()
                    
                }
            }
        }
        
        
        locationField.itemSelectionHandler = { filteredResults, itemPosition in
            
            let temp = filteredResults[itemPosition] as! MapItemSearchResult
            
            
            let searchRequest = MKLocalSearch.Request(completion: temp.mapData!)
            let search = MKLocalSearch(request: searchRequest)
            
            search.start { (response, error) in
                self.chosenLocation = response?.mapItems[0].placemark.coordinate ?? CLLocationCoordinate2D()
            }
            
            self.locationField.text = temp.title + " - " + temp.subtitle!
            
        }
        
    }
    
}


extension CreateActivityVC : CLLocationManagerDelegate {
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    
    private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: (error)")
    }
}

extension CreateActivityVC: MKLocalSearchCompleterDelegate {
    
    private func completerDidUpdateResults(completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
    
}
