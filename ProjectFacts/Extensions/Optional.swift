//
//  Optional.swift
//  ProjectFacts
//
//  Created by Andre Albach on 03.03.22.
//

import Foundation

extension Optional where Wrapped == String {
    /// Indicator if `self` is nil or empty
    var isNilOrEmpty: Bool {
        guard let value = self else { return true }
        return value.isEmpty
    }
}
