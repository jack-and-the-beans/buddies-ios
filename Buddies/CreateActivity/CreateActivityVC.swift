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
class CreateActivityVC: UITableViewController, UITextViewDelegate, UITextFieldDelegate, RangeSeekSliderDelegate{
    
    @IBOutlet weak var dateSlider: RangeSeekSlider!
    //MARK: - Variables/setup
    
    var chosenLocation: CLLocationCoordinate2D!
    var locationText : String!
    var locationManager = CLLocationManager()

    var minSliderValue : CGFloat!
    var maxSliderValue : CGFloat!
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    var region : MKCoordinateRegion!
    
    var _dismissHook: (() -> Void)?

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
        
        
        let topicIDs = selectedTopics.map { $0.id }
        guard let title = titleField.text,
            let description = descriptionTextView.text else { return }
        
        //display pop up corresponding to missing field
        if let errorText = isValidActivityData(){
            
            let alert = UIAlertController(title: "Finish Suggesting Activity", message: "Please enter information for the " + errorText + " field.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                self.present(alert, animated: true)
        
        }else
        {
            saveActivityToFirestore(
                title: title,
                description: description,
                location: GeoPoint(latitude: chosenLocation.latitude,
                                   longitude: chosenLocation.longitude),
                location_text: locationText,
                start_time: getSliderDate(sliderValue: minSliderValue),
                end_time: getSliderDate(sliderValue: maxSliderValue),
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
        
        dateSlider.delegate = self
        dateSlider.tintColor = UIColor.lightGray
        
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
        topicPicker.selectedTopics = selectedTopics
        
    }
    
    @IBAction func unwindPickTopics(sender: UIStoryboardSegue) {
        if let source = sender.source as? TopicsVC {
            selectedTopics = source.selectedTopics
        }
    }
    
    @IBAction func unwindCancelPickTopics(sender: UIStoryboardSegue) {
        
    }
    
    func isValidActivityData() -> String?{
    
        
        titleField.layer.borderColor = UIColor.clear.cgColor
        locationField.layer.borderColor = UIColor.clear.cgColor
        descriptionTextView.layer.borderColor = UIColor.clear.cgColor
        
    
        if (titleField.text?.isEmpty)! {
            titleField.layer.borderWidth = 1.0
            titleField.layer.borderColor = UIColor.red.cgColor.copy(alpha: 0.5)
            return "title"
        } else if chosenLocation == nil {
            locationField.layer.borderWidth = 1.0
            locationField.layer.borderColor = UIColor.red.cgColor.copy(alpha: 0.5)
            return "location"
        } else if selectedTopics.count == 0 {
            return "topic"
        }else if descriptionTextView.text == "Description"{
            descriptionTextView.layer.borderWidth = 1.0
            descriptionTextView.layer.borderColor = UIColor.red.cgColor.copy(alpha: 0.5)
            return "description"
        }
        
        return nil
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
    
    func getSliderString(sliderValue: CGFloat) -> String
    {
        switch sliderValue {
        case 1:
            return "Today"
        case 2:
            return "Tomorrow"
        case 3:
            return "Next 3 Days"
        case 4:
            return "Next Week"
        case 5:
            return "Next 2 Weeks"
        case 6:
            return "Next Month"
        default:
            return "Today"
        }

    }
 
    
    func getSliderDate(sliderValue: CGFloat) -> Date {
        
        var dateComponent = DateComponents()
        
        switch sliderValue {
        case 1:
            dateComponent.day = 0
        case 2:
            dateComponent.day = 1
        case 3:
            dateComponent.day = 3
        case 4:
            dateComponent.day = 7
        case 5:
            dateComponent.day = 14
        case 6:
            dateComponent.day = 30
        default:
            dateComponent.day = 0
        }
        
        return Calendar.current.date(byAdding: dateComponent, to: Date())!
        
    }
    
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMinValue minValue: CGFloat) -> String? {
        
        minSliderValue = minValue
        return getSliderString(sliderValue: minValue)
        
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMaxValue maxValue: CGFloat) -> String? {

        maxSliderValue = maxValue
        return getSliderString(sliderValue: maxValue)
        
    }
    
    func setChosenLocation(location:MapItemSearchResult)
    {
        let searchRequest = MKLocalSearch.Request(completion: location.mapData!)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { (response, error) in
            self.chosenLocation = response?.mapItems[0].placemark.coordinate ?? CLLocationCoordinate2D()
        }
        
         self.locationText = location.title
    }
    
    //MARK: - Location field
    func configureSearchTextField()
    {
        
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


