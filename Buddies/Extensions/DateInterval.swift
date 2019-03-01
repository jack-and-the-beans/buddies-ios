//
//  DateInterval.swift
//  Buddies
//
//  Created by Luke Meier on 2/14/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import Foundation
import SwiftDate

extension DateInterval {
    func rangePhrase(relativeTo now: Date, format: SymbolFormatStyle) -> String {
        let shortRangeThreshold = 1.weeks.timeInterval
        let weekRangeThreshold = 3.weeks.timeInterval
        let monthRangeThreshold = 3.months.timeInterval
        
        if duration <= shortRangeThreshold {
            return shortRangePhrase(relativeTo: now, dayFormat: format)
        } else if duration <= weekRangeThreshold {
            return weekRangePhrase(relativeTo: now)
        } else if duration <= monthRangeThreshold {
            return monthRangePhrase(relativeTo: now, monthFormat: format)
        } else {
            let startStr = self.start.calendarString(relativeTo: now, dayFormat: format)
            let endStr = self.end.calendarString(relativeTo: now, dayFormat: format)
            return "\(startStr) - \(endStr)"
        }
    }
    
    func rangePhrase(relativeTo now: Date, tryShorteningIfLongerThan threshold: Int = 15) -> String {
        let phrase = rangePhrase(relativeTo: now, format: .default)
        if phrase.count <= threshold {
            return phrase
        } else {
            return rangePhrase(relativeTo: now, format: .short)
        }
    }

    
    func weekRangePhrase(relativeTo now: Date) -> String{
        let weeksLeft = (end-now).weekOfYear! + Int(round(Double((end-now).day!/7)))
        let overlappingThisWeek = start.isBeforeDate(now, orEqual: true, granularity: .day)
                                  && end.isAfterDate(now, orEqual: true, granularity: .day)
        
        if weeksLeft < 2 && (start.compare(.isSameWeek(now)) || overlappingThisWeek)  {
            return "this week"
        } else if start.compare(.isSameWeek(now)) || overlappingThisWeek {
            return "next \(weeksLeft) weeks"
        } else if (now + 1.weeks).compare(.isSameWeek(start)) {
            return "next week"
        } else if (now - 1.weeks).compare(.isSameWeek(end)) {
            return "last week"
        } else if end < now {
            return end.toRelative(since: DateInRegion(now), style: RelativeFormatter.defaultStyle(), locale: Locales.english)
        } else {
            return start.toRelative(since: DateInRegion(now), style: RelativeFormatter.defaultStyle(), locale: Locales.english)
        }
    }
    
    func monthRangePhrase(relativeTo now: Date, monthFormat: SymbolFormatStyle = .default) -> String{
        let monthsLeft = (end-now).month! + Int(round(Double((end-now).weekOfYear!/5)))
        let overlappingThisMonth = start.isBeforeDate(now, orEqual: true, granularity: .day)
                                  && end.isAfterDate(now, orEqual: true, granularity: .day)

        if monthsLeft < 2 && (start.compare(.isSameMonth(now)) || overlappingThisMonth) {
            return "this month"
        } else if overlappingThisMonth {
            return "next \(monthsLeft) months"
        } else if (now + 1.months).compare(.isSameMonth(start)) {
            return "next month"
        } else if (now - 1.months).compare(.isSameMonth(end)) {
            return "last month"
        } else if start.compareCloseTo(now, precision: 1.years.timeInterval) {
            return "next \(start.monthName(monthFormat))"
        } else if end.compareCloseTo(now, precision: 1.years.timeInterval) {
            return "last \(end.monthName(monthFormat))"
        } else if end < now {
            return end.toRelative(since: DateInRegion(now), style: RelativeFormatter.defaultStyle(), locale: Locales.english)
        } else {
            return start.toRelative(since: DateInRegion(now), style: RelativeFormatter.defaultStyle(), locale: Locales.english)
        }
    }
    
    func shortRangePhrase(relativeTo now: Date, dayFormat: SymbolFormatStyle = .default) -> String {
        
        let timeDiff = (start-now)
        let isWeekend = start.isInWeekend && end.isInWeekend
        
        if start <= now && now <= end {
            return "through \(end.calendarString(relativeTo: now, dayFormat: dayFormat))"
        } else if now < start && timeDiff.weekOfYear == 0 && isWeekend {
            return "this weekend"
        } else if timeDiff.weekOfYear == 1 && isWeekend {
            return "next weekend"
        } else if end < now && timeDiff.weekOfYear! > -1 && isWeekend {
            return "last weekend"
        } else if timeDiff.weekOfYear == 0 {
            return "\(start.calendarString(relativeTo: now, dayFormat: dayFormat)) - \(end.calendarString(relativeTo: now, dayFormat: dayFormat))"
        } else if end < now {
            return end.toRelative(since: DateInRegion(now), style: RelativeFormatter.defaultStyle(), locale: Locales.english)
        } else {
             return start.toRelative(since: DateInRegion(now), style: RelativeFormatter.defaultStyle(), locale: Locales.english)
        }
        
    }
    
}

extension Date {
    func calendarString(relativeTo now: Date,
                        monthFormat: SymbolFormatStyle = .short,
                        dayFormat:   SymbolFormatStyle = .default) -> String {
        
        if      compare(.isSameDay(now))            { return "today" }
        else if compare(.isSameDay(now + 1.days))   { return dayFormat == .short ? "\(weekdayName(dayFormat))" : "tomorrow" }
        else if compare(.isSameDay(now - 1.days))   { return dayFormat == .short ? "yest" : "yesterday" }
        else if compare(.isSameWeek(now))           { return "\(weekdayName(dayFormat))" }
        else if compare(.isSameWeek(now + 1.weeks)) { return "next \(weekdayName(dayFormat))" }
        else if compare(.isSameWeek(now - 1.weeks)) { return "last \(weekdayName(dayFormat))" }
        else { return "\(monthName(monthFormat)) \(ordinalDay)" }
    }
}
