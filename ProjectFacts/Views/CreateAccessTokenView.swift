//
//  CreateAccessTokenView.swift
//  ProjectFacts
//
//  Created by Andre Albach on 03.03.22.
//

import SwiftUI

/// A form view hich will allow the user to create an project facts access token
struct CreateAccessTokenView: View {
    
    /// Reference to the token creator
    @EnvironmentObject private var tokenCreator: AccessTokenCreator
    
    /// The body of the view
    var body: some View {
        Form {
            Section {
                TextField("Base url", text: $tokenCreator.baseURL)
                
                TextField("Your email address", text: $tokenCreator.email)
                
                SecureField("Your password", text: $tokenCreator.password)
            }
            
            Button("Create Token", action: tokenCreator.createAccessToken)
        }
    }
}


// MARK: - Preview

struct CreateAccessTokenView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccessTokenView()
            .environmentObject(AccessTokenCreator.preview)
    }
}
