//
//  DateRangeSliderDelegate.swift
//  Buddies
//
//  Created by Jake Thurman on 2/24/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import CoreGraphics

class DateRangeSliderDelegate : RangeSeekSliderDelegate {
    static let instance = DateRangeSliderDelegate()

    func getName(sliderIndex: CGFloat) -> String {
        let values = ["", "Today", "Tomorrow", "Next 3 Days", "Next Week", "Next 2 Weeks", "Next Month"]
        
        return values[Int(sliderIndex)]
    }
    
    static func getDate(sliderIndex: Int) -> Date {
        var dateComponent = DateComponents()
        
        let indexedValues = [ 0, 0, 1, 3, 7, 14, 30, 0 ]
        dateComponent.day = indexedValues[sliderIndex]
        
        return Calendar.current.date(byAdding: dateComponent, to: Date()) ?? Date()
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMinValue minValue: CGFloat) -> String? {
        return getName(sliderIndex: minValue)
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMaxValue maxValue: CGFloat) -> String? {
        return getName(sliderIndex: maxValue)
    }
}
