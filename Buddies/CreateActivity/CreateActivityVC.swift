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
class CreateActivityVC: UITableViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var dateSlider: RangeSeekSlider!
    @IBOutlet weak var suggestButton: UIBarButtonItem!
    
    //MARK: - Variables/setup
    var chosenLocation: CLLocationCoordinate2D?
    var locationText : String!
    var locationManager = CLLocationManager()

    @IBOutlet weak var titleCell: UITableViewCell!
    @IBOutlet weak var locationCell: UITableViewCell!
    @IBOutlet weak var topicCell: UITableViewCell!
    @IBOutlet weak var descriptionCell: UITableViewCell!
    
    var minSliderValue : CGFloat!
    var maxSliderValue : CGFloat!
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    var region : MKCoordinateRegion!
    
    var _dismissHook: (() -> Void)?
    
    // Used for edit activity
    var activity: Activity?

    var topicCollection: TopicCollection?
    var selectedTopics = [Topic]() {
        didSet {
            if selectedTopics.count > 0 {
                topicDetails.text = (selectedTopics.map { $0.name }).joined(separator: ", ")
            } else { topicDetails.text = "None" }
        }
    }
    
    @IBOutlet weak var topicDetails: UILabel!
    
    @IBOutlet weak var locationField: SearchTextField!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var titleField: UITextField!
    
    
    @IBAction func cancelCreateActivity(_ segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: _dismissHook)
    }
    
    @IBAction func finishCreateActivity(_ segue: UIStoryboardSegue) {
        //display pop up corresponding to missing field
        let missingFields = isValidActivityData()
        
        //If anything is empty, warn users and return early
        guard missingFields.isEmpty else {
            var errorText = missingFields[0]
            let multiple = missingFields.count > 1
            
            if multiple {
                errorText = missingFields[0..<missingFields.endIndex - 1].joined(separator: ", ") + " and " + missingFields[missingFields.endIndex - 1]
            }
            
            let alert = UIAlertController(title: "Missing information", message: "Please fill in the \(errorText) field\(multiple ? "s" : "").", preferredStyle: .alert)
                
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            return
        }
        
        guard let activityLoc = chosenLocation,
            let title = titleField.text,
            let description = descriptionTextView.text else { return }
        
        let topicIDs = selectedTopics.map { $0.id }
        let location = GeoPoint(latitude: activityLoc.latitude,
                                longitude: activityLoc.longitude)
        
        if let activity = activity {
            activity.description = description
            activity.title = title
            activity.topicIds = topicIDs
            activity.locationText = locationText
            activity.location = location
            
            dismiss(animated: true, completion: _dismissHook)
        }
        else {
            saveActivityToFirestore(
                title: title,
                description: description,
                location: location,
                location_text: locationText,
                start_time: DateRangeSliderDelegate.getDate(sliderIndex: Int(dateSlider.selectedMinValue)),
                end_time: DateRangeSliderDelegate.getDate(sliderIndex: Int(dateSlider.selectedMaxValue)),
                topicIDs: topicIDs
            )
            dismiss(animated: true, completion: _dismissHook)
        }
        
        
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
    
    
    @IBAction func newLocationSearch(_ sender: Any) {
        if let query = self.locationField.text {
            
            self.searchCompleter.queryFragment = query
            
            self.completerDidUpdateResults(completer: self.searchCompleter)
            
        }
        
        
        var displayResults:[MapItemSearchResult] = []
        
        for item in self.searchResults {
            let temp = MapItemSearchResult(title: item.title)
            temp.subtitle = item.subtitle
            temp.mapData = item
            
            if (item.subtitle != "Search Nearby")
            {
                 displayResults.append(temp)
            }
           
        }
        
        locationField.filterItems(displayResults)
    }
    
    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchCompleter.queryFragment = ""
        
        dateSlider.delegate = DateRangeSliderDelegate.instance
        dateSlider.tintColor = UIColor.lightGray
        dateSlider.handleColor = Theme.theme
        dateSlider.handleBorderColor = Theme.theme
        dateSlider.colorBetweenHandles = Theme.theme

        descriptionTextView.delegate = self
        descriptionTextView.textColor = UIColor.lightGray
        
        descriptionTextView.accessibilityIdentifier = "activityDescriptionField"
        locationField.accessibilityIdentifier = "activityLocationField"
        titleField.accessibilityIdentifier = "activityTitleField"
        
        
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
        
        // Setup for Pick topics
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        topicCollection = appDelegate.topicCollection
        
        // If this is edit, set the current state
        if let activity = activity {
            suggestButton.title = "Save"
            self.title = "Edit Activity"
            
            titleField.text = activity.title
            locationField.text = activity.locationText
            
            descriptionTextView.text = activity.description
            descriptionTextView.textColor = UIColor.black
            
            locationText = activity.locationText
            chosenLocation = CLLocationCoordinate2D(latitude: activity.location.latitude, longitude: activity.location.longitude)
            
            
            let allTopics = topicCollection?.topics ?? []
            selectedTopics = allTopics.filter({
                activity.topicIds.contains($0.id)
            })
            
            dateSlider.isEnabled = false
            dateSlider.handleColor = UIColor.lightGray
            dateSlider.handleBorderColor = UIColor.lightGray
            dateSlider.colorBetweenHandles = UIColor.lightGray
            dateSlider.maxLabelColor = UIColor.clear
            dateSlider.minLabelColor = UIColor.clear
        }
    }
    
    //MARK: - Topics
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nav = segue.destination as? UINavigationController,
            let topicPicker = nav.viewControllers[0] as? TopicsVC else { return }
        topicPicker.topicCollection = topicCollection
        topicPicker.selectedTopics = selectedTopics
        
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1, activity != nil {
            return "You can't edit the date range of an activty."
        }
        else if section == 0 {
            return "A location can be as specific as you want, from a city name to the coffeeshop you're looking to try."
        }
        else if section == 1 {
            return "The days the activity will be between - You can always nail down the details in chat later."
        }
        
        return nil
    }
    
    @IBAction func unwindPickTopics(sender: UIStoryboardSegue) {
        if let source = sender.source as? TopicsVC {
            selectedTopics = source.selectedTopics
        }
    }
    
    @IBAction func unwindCancelPickTopics(sender: UIStoryboardSegue) {
    }
    
    func isValidActivityData() -> [String]{
    
        titleCell.layer.borderColor = UIColor.clear.cgColor
        locationCell.layer.borderColor = UIColor.clear.cgColor
        topicCell.layer.borderColor = UIColor.clear.cgColor
        descriptionCell.layer.borderColor = UIColor.clear.cgColor
        
        var result = [String]()
    
        if (titleField.text?.isEmpty ?? true) {
            titleCell.layer.borderWidth = 1.0
            titleCell.layer.borderColor = UIColor.red.cgColor.copy(alpha: 0.5)
            result.append("title")
        }
        // If no location is chosen, or a location is chosen but the text is placeholder or empty
        if chosenLocation == nil || locationField.text == "Location" || locationField.text?.isEmpty ?? true {
            locationCell.layer.borderWidth = 1.0
            locationCell.layer.borderColor = UIColor.red.cgColor.copy(alpha: 0.5)
            result.append("location")
        }
        if selectedTopics.count == 0 {
            topicCell.layer.borderWidth = 1.0
            topicCell.layer.borderColor = UIColor.red.cgColor.copy(alpha: 0.5)
            result.append("topic")
        }
        if descriptionTextView.text == "Description" || descriptionTextView.text.isEmpty {
            descriptionCell.layer.borderWidth = 1.0
            descriptionCell.layer.borderColor = UIColor.red.cgColor.copy(alpha: 0.5)
            result.append("description")
        }
        
        return result
    }
    
    //MARK: - Firestore
    
    func saveActivityToFirestore(
        title: String = "Title",
        description: String = "Description",
        location: GeoPoint = GeoPoint(latitude: 0, longitude: 0),
        location_text: String = "Location",
        user: UserInfo? = Auth.auth().currentUser,
        collection: CollectionReference = Firestore.firestore().collection("activities"),
        start_time: Date = Date(),
        end_time: Date = Date(),
        topicIDs: [String]){
        
        guard let uid = user?.uid else {return}
        
        collection.addDocument(data: [
            "title": title,
            "owner_id": uid,
            "description" : description,
            "date_created": Date(),
            "location": location,
            "location_text": location_text,
            "start_time": start_time,
            "end_time": end_time,
            "topic_ids": topicIDs,
            "members": [uid]
        ])
    }
    
    func setChosenLocation(location: MapItemSearchResult) {
        let searchRequest = MKLocalSearch.Request(completion: location.mapData!)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { (response, error) in
            self.chosenLocation = response?.mapItems[0].placemark.coordinate
        }
        
        self.locationText = location.title
    }

    
    //MARK: - Location field
    func configureSearchTextField() {
        
        locationField.theme.cellHeight = 50
        locationField.maxNumberOfResults = 10
        locationField.maxResultsListHeight = 250
        locationField.minCharactersNumberToStartFiltering = 0
        locationField.comparisonOptions = [.caseInsensitive]
        locationField.theme.font = UIFont.systemFont(ofSize: 12)
        locationField.theme.bgColor = UIColor.white
        
        
        locationField.itemSelectionHandler = { filteredResults, itemPosition in
            
            let temp = filteredResults[itemPosition] as! MapItemSearchResult
            
            self.setChosenLocation(location: temp)
            
            self.locationField.text = temp.title
            
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
        print("error:: \(error)")
    }
}

extension CreateActivityVC: MKLocalSearchCompleterDelegate {
    
    private func completerDidUpdateResults(completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        
    }
    
}


