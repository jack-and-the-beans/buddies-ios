//
//  DateIntervalTests.swift
//  BuddiesTests
//
//  Created by Luke Meier on 2/16/19.
//  Copyright © 2019 Jack and the Beans. All rights reserved.
//

import XCTest
@testable import Buddies
import SwiftDate

class DateIntervalTests: XCTestCase {

    var now: Date!
    let refDate = "11/23/1998".toDate()!
    var tomorrow, yesterday: Date!
    var monday, tuesday, wednesday, thursday, friday, saturday, sunday: Date!
    
    override func setUp() {
        monday = refDate.dateAt(.nextWeekday(.monday)).date
        tuesday = monday.dateAt(.nextWeekday(.tuesday)).date
        wednesday = tuesday.dateAt(.nextWeekday(.wednesday)).date
        thursday = wednesday.dateAt(.nextWeekday(.thursday)).date
        friday = thursday.dateAt(.nextWeekday(.friday)).date
        saturday = friday.dateAt(.nextWeekday(.saturday)).date
        sunday = saturday.dateAt(.nextWeekday(.sunday)).date
        
        now = Date()
        tomorrow = now.dateAt(.tomorrow)
        yesterday = now.dateAt(.yesterday)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWeekendShortRange(){
        let week: [Date] = [monday, tuesday, wednesday, thursday]
        for relativeTo in week {
            let friday = relativeTo.dateAt(.nextWeekday(.friday))
            let saturday = friday.dateAt(.nextWeekday(.saturday))
            let sunday = saturday.dateAt(.nextWeekday(.sunday))
            
            
            //MARK: This weekend
            let strictThisWeekend = DateInterval(start: saturday, end: sunday)
            let looseThisWeekend = DateInterval(start: friday, end: sunday)
            
            XCTAssert(strictThisWeekend.rangePhrase(relativeTo: relativeTo)
                == "this weekend", "Sat-Sun should be 'this weekend' relative to \(relativeTo.weekdayName(.default))")
            
            XCTAssert(looseThisWeekend.rangePhrase(relativeTo: relativeTo)
                != "this weekend", "Fri-Sun should not be 'this weekend' relative to \(relativeTo.weekdayName(.default))")
            
            
            //MARK: Last weekend
            let strictLastWeekend = DateInterval(start: saturday - 1.weeks, end: sunday - 1.weeks)
            let looseLastWeekend = DateInterval(start: friday - 1.weeks, end: sunday - 1.weeks)
            
            XCTAssert(strictLastWeekend.rangePhrase(relativeTo: relativeTo)
                == "last weekend", "Last Sat-Sun should be 'last weekend' relative to \(relativeTo.weekdayName(.default))")
            
            XCTAssert(looseLastWeekend.rangePhrase(relativeTo: relativeTo)
                != "last weekend", "Last Fri-Sun should not be 'last weekend' relative to \(relativeTo.weekdayName(.default))")
            
            //MARK: Next weekend
            let strictNextWeekend = DateInterval(start: saturday + 1.weeks, end: sunday + 1.weeks)
            let looseNextWeekend = DateInterval(start: friday + 1.weeks, end: sunday + 1.weeks)
            
            XCTAssert(strictNextWeekend.rangePhrase(relativeTo: relativeTo)
                == "next weekend", "Next Sat-Sun should be 'next weekend' relative to \(relativeTo.weekdayName(.default))")
            
            XCTAssert(looseNextWeekend.rangePhrase(relativeTo: relativeTo)
                != "next weekend", "Next Fri-Sun should not be 'next weekend' relative to \(relativeTo.weekdayName(.default))")
        }
        
    }
    
    func testShortRangeString_Present() {
        
        let yestThruTom = DateInterval(start: yesterday, end: tomorrow)
        
        XCTAssert(yestThruTom.shortRangePhrase(relativeTo: now)
            == "through tomorrow")
    }
    
    func testShortRangeString_UpcomingClose() {
        let friThruSat = DateInterval(start: friday, end: friday + 1.days)
        
        XCTAssert(friThruSat.shortRangePhrase(relativeTo: wednesday)
            == "Friday through Saturday")
        
        let monThruThurs = DateInterval(start: monday, end: monday.dateAt(.nextWeekday(.thursday)))
        
        XCTAssert(monThruThurs.shortRangePhrase(relativeTo: saturday)
            == "Monday through Thursday")
    }
    
    func testShortRangeString_toRelative(){
        let tenDaysAgo = DateInterval(start: now - 20.days, end: now
        - 10.days)
        
        XCTAssert(tenDaysAgo.shortRangePhrase(relativeTo: now) == "a week ago")
        
        let tenDaysAhead = DateInterval(start: now + 10.days, end: now
            + 20.days)

        XCTAssert(tenDaysAhead.shortRangePhrase(relativeTo: now) == "in a week")
    }
    
    func testWeekRangeString_Past(){
        let tenDaysAgo = DateInterval(start: monday - 30.days, end: monday - 10.days)
        XCTAssert(tenDaysAgo.weekRangePhrase(relativeTo: monday) == "a week ago")
        
        let twentyDaysAgo = DateInterval(start: monday - 30.days, end: monday - 20.days)
        XCTAssert(twentyDaysAgo.weekRangePhrase(relativeTo: monday) == "3 weeks ago")
        
        let lastWeek = DateInterval(start: monday - 30.days, end: monday - 4.days)
        XCTAssert(lastWeek.weekRangePhrase(relativeTo: monday) == "last week")
    }
        
    func testWeekRangeString_Future(){
        let tenDaysAheadMonday = DateInterval(start: monday + 10.days, end: monday + 20.days)
        XCTAssert(tenDaysAheadMonday.weekRangePhrase(relativeTo: monday) == "next week")
        
        let tenDaysAheadFri = DateInterval(start: friday + 10.days, end: friday + 20.days)
        XCTAssert(tenDaysAheadFri.weekRangePhrase(relativeTo: friday) == "in a week")
        
        let twentyDaysAhead = DateInterval(start: monday + 20.days, end: monday + 30.days)
        XCTAssert(twentyDaysAhead.weekRangePhrase(relativeTo: monday) == "in 3 weeks")
        
        let nextWeek = DateInterval(start: monday + 7.days, end: monday + 12.days)
        XCTAssert(nextWeek.weekRangePhrase(relativeTo: monday) == "next week")
    }
        
    func testWeekRangeString_Present() {
        let thisWeek = DateInterval(start: monday - 2.days, end: monday + 2.days)
        XCTAssert(thisWeek.weekRangePhrase(relativeTo: monday) == "this week")
        
        let nextTwoWeeks = DateInterval(start: monday - 2.days, end: monday + 14.days)
        XCTAssert(nextTwoWeeks.weekRangePhrase(relativeTo: monday) == "next 2 weeks")
    }
    
    
    func testMonthRangeString_NearNow() {
        let thisMonth = DateInterval(start: monday.dateAt(.startOfMonth), end: monday.dateAt(.endOfMonth))
        
        XCTAssert(thisMonth.monthRangePhrase(relativeTo: monday) == "this month")
        
        let nextMonth = DateInterval(start: monday.dateAt(.nextMonth), end:  monday.dateAt(.nextMonth).dateAt(.endOfMonth))
        
        XCTAssert(nextMonth.monthRangePhrase(relativeTo: monday) == "next month")

        let lastMonth = DateInterval(start: monday.dateAt(.prevMonth), end:  monday.dateAt(.prevMonth).dateAt(.endOfMonth))
        
        XCTAssert(lastMonth.monthRangePhrase(relativeTo: monday) == "last month")

        let next2Months = DateInterval(start: monday.dateAt(.startOfMonth), end: monday.dateAt(.startOfMonth) + 2.months)
        
        XCTAssert(next2Months.monthRangePhrase(relativeTo: monday.dateAt(.startOfMonth)) == "next 2 months")
    }
    
    func testMonthRangeString_MonthName(){
        let dec = monday - 11.months
        let oct = monday + 11.months
        let lastDec = DateInterval(start: dec - 2.months, end:  dec )
        let nextOct = DateInterval(start: oct, end:  oct + 2.months)

        XCTAssert(lastDec.monthRangePhrase(relativeTo: monday) == "last December")

        XCTAssert(nextOct.monthRangePhrase(relativeTo: monday) == "next October")
    }
    
    func testMonthRangeString_toRelative(){
        for i in 0...10 {
            let pastRange = DateInterval(start: monday - (i + 2).months, end: monday - (i + 1).months)
            let pastStr = pastRange.end.toRelative(since: DateInRegion(monday),
                                                   style: RelativeFormatter.defaultStyle(),
                                                   locale: Locales.english)
                
            XCTAssert(pastRange.weekRangePhrase(relativeTo: monday) == pastStr, "use toRelative for dates ending \(i+1) months in the past")
            
            let futureRange = DateInterval(start: monday + (i + 1).months, end: monday + (i + 2).months)
            let futureStr = futureRange.start.toRelative(since: DateInRegion(monday),
                                                         style: RelativeFormatter.defaultStyle(),
                                                         locale: Locales.english)
             XCTAssert(futureRange.weekRangePhrase(relativeTo: monday) == futureStr, "use toRelative for dates starting \(i+1) months in the future")
        }
    }
    
    func testGeneralRangeString_Short(){
        let shortGap = DateInterval(start: monday, duration: 3.days.timeInterval)
        XCTAssert(shortGap.rangePhrase(relativeTo: monday) == shortGap.shortRangePhrase(relativeTo: monday))
    }

    func testGeneralRangeString_Weeks(){
        let oneWeek = DateInterval(start: monday, duration: 1.weeks.timeInterval)
        XCTAssert(oneWeek.rangePhrase(relativeTo: monday) == oneWeek.shortRangePhrase(relativeTo: monday))
        
        let threeWeek = DateInterval(start: monday, duration: 3.weeks.timeInterval)
        XCTAssert(threeWeek.rangePhrase(relativeTo: monday) == threeWeek.weekRangePhrase(relativeTo: monday))

        let fourWeek = DateInterval(start: monday, duration: 4.weeks.timeInterval)
        XCTAssert(fourWeek.rangePhrase(relativeTo: monday) == fourWeek.monthRangePhrase(relativeTo: monday))
    }

    func testGeneralRangeString_Months(){
        
        let oneMonth = DateInterval(start: monday, duration: 1.months.timeInterval)
        XCTAssert(oneMonth.rangePhrase(relativeTo: monday) == oneMonth.monthRangePhrase(relativeTo: monday))

        let twoMonth = DateInterval(start: monday, duration: 2.months.timeInterval)
        XCTAssert(twoMonth.rangePhrase(relativeTo: monday) == twoMonth.monthRangePhrase(relativeTo: monday))
        
        let threeMonth = DateInterval(start: monday, duration: 3.months.timeInterval)
        XCTAssert(threeMonth.rangePhrase(relativeTo: monday) == threeMonth.monthRangePhrase(relativeTo: monday))
    }
    func testGeneralRangeString_Years(){
        let huge = DateInterval(start: monday, duration: 3.years.timeInterval)
        XCTAssert(huge.rangePhrase(relativeTo: monday) == "today through \(huge.end.calendarString(relativeTo: monday))")
    }

}
