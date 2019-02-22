//
//  SearchHandler.swift
//  Buddies
//
//  Created by Jake Thurman on 2/20/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import UIKit

typealias SearchParams = (filterText: String?, when: DateInterval?, maxMetersAway: Int)

protocol FilterSearchBarDelegate {
    func endEditing()
    func display(activities: [ActivityId])
    func getTopics() -> [String]
}

class FilterSearchBar : UISearchBar, UISearchBarDelegate {
    let api: AlgoliaSearch
    
    var displayDelegate: FilterSearchBarDelegate?
    
    // Default is a sentinal because XCode hates nil tuples :(
    var lastSearchParams: SearchParams = ("", nil, 0)
    
    var searchTimer: Timer?
    var filterMenu: UIView?
    
    override init(frame: CGRect) {
        self.api = AlgoliaSearch()
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.api = AlgoliaSearch()
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    private func setupView() {
        // I'm my own delegate!
        self.delegate = self
        
        // Create the filter button
        renderFilterButton()
    }
    
    private func renderFilterButton() {
        let bttn = UIButton(type: .custom)
        
        // Event handler
        bttn.addTarget(self, action: #selector(self.onFilterTapped), for: .touchUpInside)
        
        // Design
        bttn.setTitle("Filter", for: .normal)
        bttn.backgroundColor = ControlColors.theme
        bttn.setTitleColor(UIColor.white, for: .normal)
        bttn.translatesAutoresizingMaskIntoConstraints = false
        
        // Rounded corners
        bttn.clipsToBounds = true
        bttn.layer.cornerRadius = 10
        bttn.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        
        addSubview(bttn)
        
        // Size/Position
        NSLayoutConstraint.activate([
            bttn.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            bttn.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            bttn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            bttn.widthAnchor.constraint(equalToConstant: 65)
        ])
    }
    
    func renderNewFilterMenu() -> UIView {
        let height = CGFloat(200)
        let container = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: height))
        container.backgroundColor = UIColor(white: 0.98, alpha: 0.85)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // Rounded corners
        container.clipsToBounds = true
        container.layer.cornerRadius = 10
        
        // render
        superview?.addSubview(container)
        
        // Size/Position
        NSLayoutConstraint.activate([
            container.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            container.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            container.topAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            container.heightAnchor.constraint(equalToConstant: height)
        ])
        
        return container
    }
    
    @objc func onFilterTapped() {
        // Hide the filter menu...
        if let filterMenu = filterMenu {
            filterMenu.removeFromSuperview()
            self.filterMenu = nil
            return
        }
        
        // Show the filter menu...
        self.filterMenu = renderNewFilterMenu()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchTimer?.invalidate()
        
        displayDelegate?.endEditing()
        fetchAndLoadActivities()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchTimer?.invalidate()
        fetchAndLoadActivities()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // Create a timer to reload stuff so that we don't just call algolia for every time a letter is pressed in the search bar
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            self.fetchAndLoadActivities()
        }
    }
    
    func getSearchParams() -> SearchParams {
        let text = self.text == "" ? nil : self.text
        
        // TODO: the DateInterval and location radius are hardcoded for now
        //       this will change soon in coming BUD- stories ;)
        return (text, nil, 20000)
    }
    
    func fetchAndLoadActivities() {
        let myParams = getSearchParams()
        
        //Cancel if nothing has changed
        if lastSearchParams == myParams { return }
        
        // Store request params #NoRaceConditions
        self.lastSearchParams = myParams
        
        // Load data from algolia!
        api.searchActivities(withText: myParams.filterText,
                             matchingAnyTopicOf: displayDelegate?.getTopics(),
                             startingAt: myParams.when?.start,
                             endingAt: myParams.when?.end,
                             upToDisatnce: myParams.maxMetersAway) {
            (activities: [ActivityId], err: Error?) in
            
            // Cancel if we've made a new request #NoRaceConditions
            if self.lastSearchParams != myParams { return }
            
            // Handle errors
            if let error = err { print(error) }
            
            // Load new data
            self.displayDelegate?.display(activities: activities)
        }
    }
}
