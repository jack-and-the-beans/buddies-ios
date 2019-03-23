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
    func fetchAndLoadActivities(for params: SearchParams?)
}

class FilterSearchBar : UISearchBar, UISearchBarDelegate {
    private static let metersPerMile: CGFloat = 1609.344
    
    var displayDelegate: FilterSearchBarDelegate?
    
    // This just uses default values for now
    //  these probably need to be stored in
    //  firestore for BUD-41 🤔
    var lastFilterState: FilterState = ("", 1, 6, 200)
    var nextLocationRange: CGFloat?
    var nextDateRange: (Int, Int)?
    
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
    
    private func makeFilterButton(doing action: Selector, rounding corners: CACornerMask) -> UIButton {
        let bttn = makeButton(saying: "Filter", doing: action)
        
        // Design
        bttn.backgroundColor = ControlColors.theme
        bttn.setTitleColor(ControlColors.white, for: .normal)
        bttn.translatesAutoresizingMaskIntoConstraints = false
        
        // Rounded corners
        bttn.clipsToBounds = true
        bttn.layer.cornerRadius = ControlColors.cornerRadius
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
        slider.handleColor = ControlColors.theme
        slider.handleBorderColor = ControlColors.theme
        slider.colorBetweenHandles = ControlColors.theme
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
        dateSlider.selectedMinValue = CGFloat(lastFilterState.dateMin)
        dateSlider.selectedMaxValue = CGFloat(lastFilterState.dateMax)
        
        let locationRangeSlider = makeSlider(from: 1, to: 200)
        locationRangeSlider.selectedMaxValue = lastFilterState.maxMilesAway
        locationRangeSlider.disableRange = true
        
        // Make labels
        let dateSliderLabel = makeLabel(saying: "When:")
        let locationSliderLabel = makeLabel(saying: "Distance (miles):")
        
        // Make buttons
        let innerFilterButton = BuddyButton.makeButton(saying: "Filter", doing: #selector(self.saveFilterMenu), from: self)
        let cancelButton = makeButton(saying: "Cancel", doing: #selector(self.closeFilterMenu))
        cancelButton.setTitleColor(ControlColors.themeAlt, for: .normal)

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
        return (container: container, locationRangeSlider: locationRangeSlider, dateSlider: dateSlider)
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
    
    func getSearchParams(from state: FilterState? = nil) -> SearchParams {
        let myState = state ?? getFilterState()
        
        let start = DateRangeSliderDelegate.getDate(sliderIndex: myState.dateMin)
        let end = DateRangeSliderDelegate.getDate(sliderIndex: myState.dateMax)
        let distance = Int(FilterSearchBar.metersPerMile * myState.maxMilesAway)
        
        return (myState.filterText, start, end, distance)
    }
    
    func sendParams(to target: FilterSearchBarDelegate?) {
        
        // If there is a timer, invalidate it! We're searching now.
        searchTimer?.invalidate()

        let myState = getFilterState()
        
        if lastFilterState == myState { return }
        
        // Store request params #NoRaceConditions
        self.lastFilterState = myState
        
        let params = getSearchParams(from: myState)
        
        // pass params to FilterSearchBarDelegate
        target?.fetchAndLoadActivities(for: params)
    }
}
