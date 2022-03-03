//
//  ComponentsFormatStyle.swift
//  ProjectFacts
//
//  Created by Andre Albach on 03.03.22.
//

import Foundation

extension Date.ComponentsFormatStyle {
    /// Will use a extended version of the time duration.
    /// Format style will llok like this: days[d] hours:minutes:seconds
    static var extendedTimeDuration: Date.ComponentsFormatStyle = {
        var style = Date.ComponentsFormatStyle.timeDuration
        style.fields = [.day, .hour, .minute, .second]
        return style
    }()
}
