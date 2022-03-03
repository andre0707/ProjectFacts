//
//  DateFormatter.swift
//  ProjectFacts
//
//  Created by Andre Albach on 03.03.22.
//

import Foundation

extension DateFormatter {
    /// A date formatter which will return a date (without time) formatted in a way project facts API will accept
    static let pfCompatible: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter
    }()
    
    /// A static variable with a configured date formatter with the full iso 8601 date format
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSxxxxx"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
