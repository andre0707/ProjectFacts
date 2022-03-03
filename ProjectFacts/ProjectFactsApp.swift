//
//  ProjectFactsApp.swift
//  ProjectFacts
//
//  Created by Andre Albach on 03.03.22.
//

import SwiftUI

@main
struct ProjectFactsApp: App {
    
    /// Reference to the main app controller
    @StateObject private var appController = AppController()
    
    /// The body of the app
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(appController)
                .environmentObject(appController.accessTokenCreator)
        }
    }
}
