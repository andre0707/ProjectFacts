//
//  MainView.swift
//  ProjectFacts
//
//  Created by Andre Albach on 03.03.22.
//

import SwiftUI

/// The main app view
struct MainView: View {
    
    /// Referenece to the app controller
    @EnvironmentObject private var appController: AppController
    
    /// The body of the view
    var body: some View {
        Group {
            if appController.presentLoginForm {
                WelcomeView()
            } else {
                TimesTableView()
                    .frame(minWidth: 800, idealWidth: 800, minHeight: 500, idealHeight: 500)
            }
        }
        
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    appController.presentLoginForm = true
                }, label: {
                    Label("Login", systemImage: "rectangle.and.pencil.and.ellipsis")
                })
            }
            
            ToolbarItem(placement: .navigation) {
                DatePicker("", selection: $appController.ticketDate, in: Date.distantPast ... Date(), displayedComponents: .date)
            }
            
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    appController.readTimes()
                }, label: {
                    Label("Read times", systemImage: "play.fill")
                })
            }
        }
    }
}


// MARK: - Preview

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AppController.preview)
            .environmentObject(AppController.preview.accessTokenCreator)
    }
}
