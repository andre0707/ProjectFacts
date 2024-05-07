//
//  PFTimeEntry.swift
//  ProjectFacts
//
//  Created by Andre Albach on 03.03.22.
//

import Foundation

/// A simple structure to hold a project facts time entry
struct PFTimeEntry: Identifiable {
    /// Unique id for the entrz
    let id: Int
    /// The duration
    let duration: TimeInterval
    /// The billable duration
    let billableDuration: TimeInterval
    /// The description
    let description: String
    /// The id of the ticket on which this time entry was booked
    let ticketId: Int?
    
    
    /// Text representation of `duration`
    var durationText: String { duration.formatted() }
    /// Text representation of `billableDuration`
    var billableDurationText: String { billableDuration.formatted() }
    /// Text representation of `ticketId`
    var ticketIdText: String {
        guard let ticketId else { return "" }
        return "\(ticketId)"
    }
}
