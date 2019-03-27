//
//  SearchHandler.swift
//  Buddies
//
//  Created by Jake Thurman on 2/20/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import UIKit

typealias SearchParams = (filterText: String?, startDate: Date, endDate: Date, maxMetersAway: Int)
typealias FilterState = (filterText: String?, dateMin: Int, dateMax: Int, maxMilesAway: CGFloat)
typealias FilterMenuElements = (container: UIView, locationRangeSlider: RangeSeekSlider, dateSlider: RangeSeekSlider)

protocol FilterSearchBarDelegate {
    func endEditing()
    func fetchAndLoadActivities(force: Bool)
}

class FilterSearchBar : UISearchBar, UISearchBarDelegate {
    private static let metersPerMile: CGFloat = 1609.344
    static var defaultSettings = ["dateMin": 1, "dateMax": 6, "maxMilesAway": 200]
    
    var displayDelegate: FilterSearchBarDelegate?
    
    var lastFilterState: FilterState = ("", defaultSettings["dateMin"]!, defaultSettings["dateMax"]!, CGFloat(defaultSettings["maxMilesAway"]!)) {
        didSet { updateSliderValues() }
    }
    var nextLocationRange: CGFloat?
    var nextDateRange: (Int, Int)?
    var user: LoggedInUser?
    
    var searchTimer: Timer?
    var filterMenu: FilterMenuElements?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    private func setupView() {
        // I'm my own delegate!
        self.delegate = self
        
        // Create the filter button
        let bttn = makeFilterButton(
            saying: "Filter",
            doing: #selector(self.onFilterTapped),
            rounding: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner])
        
        addSubview(bttn)
        
        // Size/Position
        NSLayoutConstraint.activate([
            bttn.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            bttn.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            bttn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            bttn.widthAnchor.constraint(equalToConstant: 65)
        ])
    }
    
    func provideLoggedInUser(_ user: LoggedInUser?) {
        self.user = user
        
        var filterSettings = user?.filterSettings ?? FilterSearchBar.defaultSettings
        
        // Convert to a filter state tuple
        self.lastFilterState = (
            self.lastFilterState.filterText,
            filterSettings["dateMin"]!,
            filterSettings["dateMax"]!,
            CGFloat(filterSettings["maxMilesAway"]!)
        )
    }
    
    private func makeFilterButton(saying: String, doing action: Selector, rounding corners: CACornerMask) -> UIButton {
        let bttn = makeButton(saying: saying, doing: action)
        
        // Design
        bttn.backgroundColor = Theme.theme
        bttn.setTitleColor(Theme.white, for: .normal)
        bttn.translatesAutoresizingMaskIntoConstraints = false
        
        // Rounded corners
        bttn.clipsToBounds = true
        bttn.layer.cornerRadius = Theme.cornerRadius
        bttn.layer.maskedCorners = corners
        
        return bttn
    }
    
    func makeSlider(from min: CGFloat, to max: CGFloat) -> RangeSeekSlider {
        let slider = RangeSeekSlider(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        slider.minValue = min
        slider.maxValue = max
        
        slider.enableStep = true
        slider.step = 1
        
        slider.tintColor = UIColor.lightGray
        slider.handleColor = Theme.theme
        slider.handleBorderColor = Theme.theme
        slider.colorBetweenHandles = Theme.theme
        slider.lineHeight = 2
        slider.labelPadding = 2
        slider.handleBorderWidth = 2
        slider.minLabelColor = UIColor.black
        slider.maxLabelColor = UIColor.black
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        return slider
    }
    
    func makeLabel(saying text: String) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        return label
    }
    
    func makeButton(saying text: String, doing action: Selector) -> UIButton {
        let bttn = UIButton(type: .system)
        bttn.setTitle(text, for: .normal)
        bttn.translatesAutoresizingMaskIntoConstraints = false
        bttn.addTarget(self, action: action, for: .touchUpInside)
        return bttn
    }
    
    func updateSliderValues() {
        filterMenu?.dateSlider.selectedMinValue = CGFloat(lastFilterState.dateMin)
        filterMenu?.dateSlider.selectedMaxValue = CGFloat(lastFilterState.dateMax)

        filterMenu?.locationRangeSlider.selectedMaxValue = lastFilterState.maxMilesAway
    }
    
    func renderNewFilterMenu() -> FilterMenuElements {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        container.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.zPosition = 2000
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        // Make sliders
        let dateSlider = makeSlider(from: 1, to: 6)
        dateSlider.delegate = DateRangeSliderDelegate.instance
        dateSlider.minDistance = 1
        
        let locationRangeSlider = makeSlider(from: 1, to: 200)
        locationRangeSlider.disableRange = true
        
        // Make labels
        let dateSliderLabel = makeLabel(saying: "When:")
        let locationSliderLabel = makeLabel(saying: "Distance (miles):")
        
        // Make buttons
        let innerFilterButton = BuddyButton.makeButton(saying: "Save Filter", doing: #selector(self.saveFilterMenu), from: self)
        let cancelButton = makeButton(saying: "Cancel", doing: #selector(self.closeFilterMenu))
        cancelButton.setTitleColor(Theme.themeAlt, for: .normal)

        // put things together
        let containerChildren = [
            dateSliderLabel,
            dateSlider,
            locationSliderLabel,
            locationRangeSlider,
            innerFilterButton,
            cancelButton,
        ]
        container.addSubview(blurView)
        containerChildren.forEach { container.addSubview($0) }
        
        let parent = superview! // Get the window in an ugly way
        
        parent.addSubview(container)

        container.bindFrameToSuperviewBounds()
        blurView.bindFrameToSuperviewBounds()
        
        // Size/Position
        let childToContainerConstraints = [
            dateSliderLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            dateSliderLabel.bottomAnchor.constraint(equalTo: dateSlider.topAnchor),
            dateSlider.bottomAnchor.constraint(equalTo: locationSliderLabel.topAnchor, constant: -20),
            locationSliderLabel.bottomAnchor.constraint(equalTo: locationRangeSlider.topAnchor),
            locationRangeSlider.bottomAnchor.constraint(equalTo: innerFilterButton.topAnchor, constant: -10),
            innerFilterButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -20)
        ]
        
        let sideConstraints = containerChildren.flatMap({ [
            $0.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 35),
            $0.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -35),
        ] })
        
        NSLayoutConstraint.activate(sideConstraints + childToContainerConstraints)
        
        // Return useful components
        return (container, locationRangeSlider, dateSlider)
    }
    
    @objc func closeFilterMenu() {
        if let filterMenu = filterMenu {
            filterMenu.container.removeFromSuperview()
            self.filterMenu = nil
        }
    }
    
    @objc func saveFilterMenu() {
        if let filterMenu = filterMenu {
            self.nextLocationRange = filterMenu.locationRangeSlider.selectedMaxValue
            self.nextDateRange = (Int(filterMenu.dateSlider.selectedMinValue), Int(filterMenu.dateSlider.selectedMaxValue))
            
            self.sendParams(to: displayDelegate)

            // Now go ahead and close
            closeFilterMenu()
        }
    }
    
    @objc func onFilterTapped() {
        // Chose existing just in the weird case that it is open
        self.closeFilterMenu()
        
        // Show the filter menu...
        self.filterMenu = renderNewFilterMenu()
        updateSliderValues()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        displayDelegate?.endEditing()
        self.sendParams(to: displayDelegate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Create a timer to reload stuff so that we don't just call algolia for every time a letter is pressed in the search bar
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.sendParams(to: self.displayDelegate)
        }
    }
    
    func getFilterState() -> FilterState {
        let text = self.text == "" ? nil : self.text
        
        let date = nextDateRange ?? (lastFilterState.dateMin, lastFilterState.dateMax)
        let location = nextLocationRange ?? lastFilterState.maxMilesAway
        
        return (text, date.0, date.1, location)
    }
    
    func getSearchParams() -> SearchParams {
        let myState = getFilterState()
        
        let start = DateRangeSliderDelegate.getDate(sliderIndex: myState.dateMin)
        let end = DateRangeSliderDelegate.getDate(sliderIndex: myState.dateMax)
        let distance = Int(FilterSearchBar.metersPerMile * myState.maxMilesAway)
        
        return (myState.filterText, start, end, distance)
    }
    
    func sendParams(to target: FilterSearchBarDelegate?) {
        
        // If there is a timer, invalidate it! We're searching now.
        searchTimer?.invalidate()

        let myState = getFilterState()
        
        // Clear the "next" variables used to store variables from the menu
        nextDateRange = nil
        nextLocationRange = nil
        
        if lastFilterState == myState { return }
        
        // Store request params #NoRaceConditions
        self.lastFilterState = myState
        
        // Write these settings away
        user?.filterSettings = [ "dateMin": lastFilterState.dateMin,
                                 "dateMax": lastFilterState.dateMax,
                                 "maxMilesAway": Int(lastFilterState.maxMilesAway) ]
        
        target?.fetchAndLoadActivities(force: false)
    }
}
