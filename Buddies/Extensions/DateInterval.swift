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
    func rangePhrase(relativeTo now: Date) -> String {
        let shortRangeThreshold = 1.weeks.timeInterval
        let weekRangeThreshold = 3.weeks.timeInterval
        let monthRangeThreshold = 3.months.timeInterval
        
        if duration <= shortRangeThreshold {
            return shortRangePhrase(relativeTo: now)
        } else if duration <= weekRangeThreshold {
            return weekRangePhrase(relativeTo: now)
        } else if duration <= monthRangeThreshold {
            return monthRangePhrase(relativeTo: now)
        } else {
            let startStr = self.start.calendarString(relativeTo: now)
            let endStr = self.end.calendarString(relativeTo: now)
            return "\(startStr) through \(endStr)"
        }
    }
    
    
    func weekRangePhrase(relativeTo now: Date) -> String{
        let weeksLeft = (end-now).weekOfYear! + Int(round(Double((end-now).day!/7)))
        let overlappingThisWeek = start.isBeforeDate(now, orEqual: true, granularity: .day)
            && end.isAfterDate(now, orEqual: true, granularity: .day)
        
        if weeksLeft < 2 && overlappingThisWeek  {
            return "this week"
        } else if overlappingThisWeek {
            return "next \(weeksLeft) weeks"
        } else if start.weekOfYear == (now + 1.weeks).weekOfYear {
            return "next week"
        } else if end.weekOfYear == (now - 1.weeks).weekOfYear {
            return "last week"
        } else if end < now {
            return end.toRelative(since: DateInRegion(now), style: RelativeFormatter.defaultStyle(), locale: Locales.english)
        } else {
            return start.toRelative(since: DateInRegion(now), style: RelativeFormatter.defaultStyle(), locale: Locales.english)
        }
    }
    
    func monthRangePhrase(relativeTo now: Date) -> String{
        let monthsLeft = (end-now).month! + Int(round(Double((end-now).weekOfYear!/5)))
        let overlappingThisMonth = start.isBeforeDate(now, orEqual: true, granularity: .day)
                                    && end.isAfterDate(now, orEqual: true, granularity: .day)
        
        if monthsLeft < 2 && overlappingThisMonth  {
            return "this month"
        } else if overlappingThisMonth {
            return "next \(monthsLeft) months"
        } else if start.month == (now + 1.months).month {
            return "next month"
        } else if end.month == (now - 1.months).month {
            return "last month"
        } else if start.compareCloseTo(now, precision: 1.years.timeInterval) {
            return "next \(start.monthName(.default))"
        } else if end.compareCloseTo(now, precision: 1.years.timeInterval) {
            return "last \(start.monthName(.default))"
        } else if end < now {
            return end.toRelative(since: DateInRegion(now), style: RelativeFormatter.defaultStyle(), locale: Locales.english)
        } else {
            return start.toRelative(since: DateInRegion(now), style: RelativeFormatter.defaultStyle(), locale: Locales.english)
        }
    }
    
    func shortRangePhrase(relativeTo now: Date) -> String {
        
        let timeDiff = (start-now)
        let isWeekend = start.isInWeekend && end.isInWeekend
        
        if start <= now && now <= end {
            return "through \(end.calendarString(relativeTo: now))"
        } else if now < start && timeDiff.weekOfYear == 0 && isWeekend {
            return "this weekend"
        } else if timeDiff.weekOfYear == 1 && isWeekend {
            return "next weekend"
        } else if end < now && timeDiff.weekOfYear ?? 0 > -1 && isWeekend {
            return "last weekend"
        } else if timeDiff.weekOfYear == 0 {
            return "\(start.calendarString(relativeTo: now)) through \(end.calendarString(relativeTo: now))"
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
        
        let sameYear = year == now.year
        
        if      dayOfYear      == now.dayOfYear  && sameYear { return "today" }
        else if dayOfYear  - 1 == now.dayOfYear  && sameYear { return "tomorrow" }
        else if dayOfYear  + 1 == now.dayOfYear  && sameYear { return "yesterday" }
        else if weekOfYear - 1 == now.weekOfYear && sameYear { return "next \(weekdayName(dayFormat))" }
        else if weekOfYear + 1 == now.weekOfYear && sameYear { return "last \(weekdayName(dayFormat))" }
        else if weekOfYear     == now.weekOfYear && sameYear { return "\(weekdayName(dayFormat))" }
        else { return "\(monthName(monthFormat)) \(ordinalDay)" }
    }
}
