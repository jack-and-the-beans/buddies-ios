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

    func getSliderString(sliderValue: CGFloat) -> String {
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
        return getSliderString(sliderValue: minValue)
    }
    
    func rangeSeekSlider(_ slider: RangeSeekSlider, stringForMaxValue maxValue: CGFloat) -> String? {
        return getSliderString(sliderValue: maxValue)
    }
}
