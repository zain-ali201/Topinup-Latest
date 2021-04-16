//
//  DateUtil.swift
//  Neighbourhoods
//
//  Created by Hanan Ahmed on 20/01/2017.
//  Copyright © 2017 Hanan. All rights reserved.
//

import Foundation

open class DateUtil {
    fileprivate static var dateFormatter:DateFormatter? = nil
    public static func getDateFormatter() -> DateFormatter {
        if dateFormatter == nil {
            dateFormatter = DateFormatter()
            dateFormatter?.dateFormat = "dd-MM-yyyy"
        }
        return dateFormatter!
    }
    
    public static func getDate(_ date:Date) -> String {
        // Day
        let calendar = Calendar.current
        let anchorComponents = calendar.dateComponents([.day, .month, .year], from: date)
        
        // Formate
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "MMM, yyyy"
        let newDate = dateFormate.string(from: date)
        
        var day  = "\(anchorComponents.day!)"
        switch (day) {
        case "1" , "21" , "31":
            day.append("st")
        case "2" , "22":
            day.append("nd")
        case "3" ,"23":
            day.append("rd")
        default:
            day.append("th")
        }
        return day + " " + newDate
    }
    
    public static func getDateWithMonthAndDay(_ date:Date) -> String
    {
        // Formate
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "MMM dd, yyyy"
        let dateWithMonthName = dateFormate.string(from: date)
        
        
        let day = DateUtil.getDay(date)
        
        return day + ", " + dateWithMonthName + DateUtil.getTimeFromDate(date)
        
    }
    
    public static func getDateWithMonthName(_ date : Date) -> String
    {
        // Formate
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "MMM dd, yyyy"
        let dateWithMonthName = dateFormate.string(from: date)
        
        return dateWithMonthName
    }
    
    public static func getDay(_ date:Date) -> String
    {
        let calendar = Calendar.current
        let anchorComponents = calendar.dateComponents([.weekday], from: date)
        let day = anchorComponents.weekday!
        
        switch day {
        case 1:
            return "Sun"
        case 2:
            return "Mon"
        case 3:
            return "Tue"
        case 4:
            return "Wed"
        case 5:
            return "Thu"
        case 6:
            return "Fri"
        case 7:
            return "Sat"
        default:
            print("Error fetching days")
            return "Day"
        }
    }
    
    public static func getsimpleDate(_ date:Date) -> String {
        let dateFormate = DateFormatter()
        dateFormate.dateFormat = "yyyy-MM-dd"
        let string = dateFormate.string(from: date)
        
        return  string
    }
    
    public static func getTimeFromDate(_ date:Date) -> String {
//        let calendar = Calendar.current
//        let hour = calendar.component(.hour, from: date)
//        let minutes = calendar.component(.minute, from: date)
//        let seconds = calendar.component(.second, from: date)
//        let time = "\(hour):\(minutes):\(seconds)"
//        return (time)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    public static func getTimeFromDates(_ startTime:Date, endTime:Date) -> String {
    //        let calendar = Calendar.current
    //        let hour = calendar.component(.hour, from: date)
    //        let minutes = calendar.component(.minute, from: date)
    //        let seconds = calendar.component(.second, from: date)
    //        let time = "\(hour):\(minutes):\(seconds)"
    //        return (time)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mma"

            
            let elapsedTime = startTime.timeIntervalSince(endTime)

            // convert from seconds to hours, rounding down to the nearest hour
            let hours = floor(elapsedTime / 60 / 60)

            // we have to subtract the number of seconds in hours from minutes to get
            // the remaining minutes, rounding down to the nearest minute (in case you
            // want to get seconds down the road)
            let minutes = floor((elapsedTime - (hours * 60 * 60)) / 60)
        
            let sec = floor((elapsedTime - (minutes * 60 * 60)) / 60)

            let timeString = "\(hours):\(minutes):\(sec)"
            return timeString
        }
    
    public static func getSimpleDateAndTime ( _ date : Date) -> String
    {
        let simpleDate = getsimpleDate(date)
        let time = getTimeFromDate(date)
        
        return simpleDate + " " + time
    }
    public static func getBookingFee(_ fare : Double) -> Double
    {
        if fare > 0
        {
            let newTotalFare = ( fare + 0.3 ) / 0.971
            let bookingFee = newTotalFare - fare
            
            return bookingFee
        }
        else
        {
            return 0.0
        }
    }
    
}

extension Double
{
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func roundedStringValue () -> String
    {
        return String(format: "%.4f", self)
    }
    
    func twoDecimalValue() -> String
    {
        return String(format: "%.2f", self)
    }
}


extension Date {
    static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
    var iso8601: String {
        return Date.iso8601Formatter.string(from: self)
    }
    
    func isEqualTo ( anotherDate : Date, ignoreTime : Bool) -> Bool
    {
        var comparisonResult : ComparisonResult
        var granularity = Calendar.Component.minute
    
        if (ignoreTime)
        {
            granularity = .day
        }

        comparisonResult  = Calendar.current.compare(self, to: anotherDate, toGranularity: granularity)
        
        if comparisonResult == .orderedSame
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    // Time Difference
    
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Date.iso8601Formatter.date(from: self)
    }
    func capitalizingFirstLetter() -> String {
        let first = String(self.prefix(1)).capitalized
        let other = String(self.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension Int {
    func withCommas() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value:self))!
    }
}
