//
//  AccessTokenCreator.swift
//  ProjectFacts
//
//  Created by Andre Albach on 03.03.22.
//

import Combine
import Foundation

/// The view model used to create a project facts access token
final class AccessTokenCreator: ObservableObject {
    
    /// The base URL
    @Published var baseURL: String = UserDefaults.standard.baseUrl
    
    /// The user email used to create the access token
    @Published var email: String = ""
    /// The user password matching to `email` to create the access token
    @Published var password: String = ""
    
    /// A publisher to notify, when the access token was created
    let didCreateAccessTokenPublisher = PassthroughSubject<Void, Never>()
    
    
    /// Initialisation
    init() {
        if let savedEmail = UserDefaults.standard.userEmail {
            self.email = savedEmail
        }
    }
    
    
    // MARK: - User intends
    
    /// This function will create the access token and store it in the user defaults
    func createAccessToken() {
        guard let url = URL(string: baseURL) else { return }
        
        UserDefaults.standard.baseUrl = baseURL
        UserDefaults.standard.userEmail = email
        
        Task {
            do {
                let response = try await ProjectFactsAPI.createAccessToken(with: email, and: password, on: url)
                UserDefaults.standard.accessId = response.tokenId
                UserDefaults.standard.accessToken = response.token
                UserDefaults.standard.userId = response.userId
                didCreateAccessTokenPublisher.send()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}


// MARK: - Preview data

extension AccessTokenCreator {
    static let preview: AccessTokenCreator = {
        let tokenCreator = AccessTokenCreator()
        
        return tokenCreator
    }()
}
