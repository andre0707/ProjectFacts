//
//  UserDefaults.swift
//  ProjectFacts
//
//  Created by Andre Albach on 03.03.22.
//

import Foundation

extension UserDefaults {
    
    /// The keys to access the user defaults
    private enum Keys {
        static let baseURL = "baseURL"
        
        static let userEmail = "userEmail"
        
        static let accessId = "accessId"
        static let accessToken = "accessToken"
        static let userId = "userId"
    }
    
    /// The project facts base URL to use
    var baseUrl: String {
        get { object(forKey: Keys.baseURL, withDefault: "http://projectfacts.de") }
        set { set(newValue, forKey: Keys.baseURL) }
    }
    
    /// Email address of the user
    var userEmail: String? {
        get { string(forKey: Keys.userEmail) }
        set { set(newValue, forKey: Keys.userEmail) }
    }
    
    /// The access token which was created for the user
    var accessToken: String? {
        get { string(forKey: Keys.accessToken) }
        set { set(newValue, forKey: Keys.accessToken) }
    }
    
    /// The access token id which was created for the user
    var accessId: Int? {
        get { object(forKey: Keys.accessId) as? Int }
        set { set(newValue, forKey: Keys.accessId) }
    }
    
    /// The user id inside project facts
    var userId: Int? {
        get { object(forKey: Keys.userId) as? Int }
        set { set(newValue, forKey: Keys.userId) }
    }
    
    /// The complete user access token
    var userAccessToken: ProjectFactsAPI.UserAccessToken? {
        guard let userId = userId,
              let token = accessToken,
              let tokenId = accessId
        else { return nil }

        return (userId: userId, tokenId: tokenId, token: token)
    }
}

extension UserDefaults {
    /// This function extends the existing get object function to pass in a default value and also the option to use the `AppSetting` enum instead of strings as the key
    /// - Parameters:
    ///   - key: The key under which the setting will be stored
    ///   - defaultValue: This value will be used if there is nothing saved for `key` yet
    /// - Returns: The stored value for `key` if there is one. `defaultValue` otherwise
    func object<T>(forKey key: String, withDefault defaultValue: T) -> T {
        return (self.object(forKey: key) as? T) ?? defaultValue
    }
}
