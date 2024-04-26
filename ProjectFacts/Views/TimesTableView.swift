//
//  TimesTableView.swift
//  ProjectFacts
//
//  Created by Andre Albach on 03.03.22.
//

import SwiftUI

/// The view which will display a list of the booked times
struct TimesTableView: View {
    
    /// Reference to the app controller
    @EnvironmentObject private var appController: AppController
    
    
    /// The body of the view
    var body: some View {
        
        VStack(alignment: .leading) {
            
            /// Table
            Table(appController.pfTicketTimes) {
                TableColumn("Description", value: \.description)
                    .width(min: 400, ideal: 400)
                TableColumn("Duration (min)", value: \.durationText)
                    .width(min: 100, ideal: 100)
                TableColumn("Billable duration (min)", value: \.billableDurationText)
                    .width(ideal: 100)
                TableColumn("Ticket id", value: \.ticketIdText)
                    .width(ideal: 100)
            }
            
            /// Time infos
            VStack(alignment: .leading, spacing: 10) {
                Text("Login at: \(appController.loginDateString)")
                
                Text("Break: \(appController.totalBreakString)")
                
                Text("Logout at: \(appController.logoutDateString)")
                
                Text("Unbooked time: \(appController.unbookedTime)")
            }
            .font(.title)
            .padding()
        }
    }
}


// MARK: Preview

struct TimesListView_Previews: PreviewProvider {
    static var previews: some View {
        TimesTableView()
            .environmentObject(AppController.preview)
    }
}
