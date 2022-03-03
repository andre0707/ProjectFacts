//
//  WelcomeView.swift
//  ProjectFacts
//
//  Created by Andre Albach on 03.03.22.
//

import SwiftUI

/// The welcome view which will also include an option to create the token
struct WelcomeView: View {
    
    /// The body of the view
    var body: some View {
        VStack {
            Text("Welcome to ProjectFacts App")
                .font(.title)
                .padding()
            
            Text("With this app you can see your booked times in Project Facts")
                .font(.title2)
                .padding()
            
            Text("Please log in:")
                .font(.title2)
                .padding()
            
            CreateAccessTokenView()
                .padding()
        }
        .frame(minWidth: 500, idealWidth: 500)
    }
}


// MARK: - Preview

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environmentObject(AppController.preview)
            .environmentObject(AppController.preview.accessTokenCreator)
    }
}
