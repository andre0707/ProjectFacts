//
//  AppController.swift
//  ProjectFacts
//
//  Created by Andre Albach on 03.03.22.
//

import Combine
import Foundation
import os

/// A logger to log errors
fileprivate let logger = Logger(subsystem: Bundle.main.bundleIdentifier, category: "AppController")


/// The app controller view model
@MainActor
final class AppController: ObservableObject {
    
    /// Indicator, if the login view should be displayed
    @Published var presentLoginForm: Bool = true
    
    
    /// The date which will be used for all evaluations
    @Published var ticketDate: Date = Date()
    
    /// A list of all the project facts tickets which are presented in the list view
    @Published private(set) var pfTicketTimes: [PFTimeEntry] = []
    
    /// The sum of all the `duration` in `pfTicketTimes`
    @Published private(set) var totalDuration: TimeInterval = 0
    /// The sum of all the `billableDuration` in `pfTicketTimes`
    @Published private(set) var totalBillableDuration: TimeInterval = 0
    
    /// The date the user logged in on `ticketDate`
    private var loginDate: Date? = nil
    /// The date the user logged out on `ticketDate`
    private var logoutDate: Date? = nil
    /// The sum of all the break time (in minutes) on ticketDate
    private var sumBreak: TimeInterval = 0
    /// A string representation of `loginDate`
    @Published private(set) var loginDateString: String = "-"
    /// A string representation of `logoutDate`
    @Published private(set) var logoutDateString: String = "-"
    /// A string representation of `sumBreak`
    @Published private(set) var totalBreakString: String = "-"
    /// A string representation of all the unbooked time
    @Published private(set) var unbookedTime: String = "-"
    
    /// Control the alert message
    @Published var showAlert: Bool = false
    @Published private(set) var alertMessage: String = "" {
        didSet {
            showAlert = true
        }
    }
    
    
    /// Reference to the access token creator which is needed when the user wants to create an access token
    let accessTokenCreator: AccessTokenCreator
    
    /// Reference to all the used subscriptions
    private var subscriptions: Set<AnyCancellable> = []
    
    /// Initialisation
    init(usePreviewData: Bool = false) {
        /// Preview
        if usePreviewData {
            accessTokenCreator = AccessTokenCreator.preview
            presentLoginForm = false
            return
        }
        
        /// No preview
        accessTokenCreator = AccessTokenCreator()
        
        presentLoginForm = UserDefaults.standard.accessToken.isNilOrEmpty
        if !presentLoginForm {
            readLogin()
        }
        
        accessTokenCreator.didCreateAccessTokenPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.presentLoginForm = UserDefaults.standard.accessToken.isNilOrEmpty
            }
            .store(in: &subscriptions)
    }
    
    
    /// This function will read all the login data for the provided `ticketDate`
    func readLogin() {
        guard let userAccessToken = UserDefaults.standard.userAccessToken,
              let baseUrl = URL(string: UserDefaults.standard.baseUrl)
        else { return }
        
        Task {
            do {
                let result = try await ProjectFactsAPI.loginTime(for: ticketDate, using: userAccessToken, on: baseUrl)
                
                DispatchQueue.main.async {
                    self.loginDate = result.begin
                    self.logoutDate = result.end
                    self.sumBreak = result.sumBreak
                    self.updateTimeStrings()
                }
            } catch {
                let errorMessage = (error as! ProjectFactsAPI.Errors).description
                logger.error("\(errorMessage)")
                
                DispatchQueue.main.async {
                    self.loginDate = nil
                    self.logoutDate = nil
                    self.sumBreak = 0
                    self.updateTimeStrings()
                    self.alertMessage = errorMessage
                }
            }
        }
    }
    
    /// This function will update all the time related strings, so the UI gets updated
    func updateTimeStrings() {
        guard let loginDate = loginDate else {
            loginDateString = "-"
            logoutDateString = "-"
            unbookedTime = "-"
            totalBreakString = "-"
            return
        }
        loginDateString = loginDate.formatted(date: .omitted, time: .shortened)
        
        let now: Date
        if let logoutDate = logoutDate {
            now = logoutDate
            logoutDateString = logoutDate.formatted(date: .omitted, time: .shortened)
        } else {
            now = Date.now
            logoutDateString = "-"
        }
        let loggedInTime = now.timeIntervalSince(loginDate)
        
        let referenceDate = now + loggedInTime - totalDuration - sumBreak * 60
        if referenceDate <= now {
            unbookedTime = "0"
        } else {
            unbookedTime = (now ..< referenceDate).formatted(Date.ComponentsFormatStyle.extendedTimeDuration)
        }
        
        totalBreakString = sumBreak > 0 ? "\(sumBreak.formatted()) min" : "-"
    }
    
    
    // MARK: - User intends
    
    /// This function will read all the booked times for the provided `ticketDate`
    func readTimes() {
        guard let userAccessToken = UserDefaults.standard.userAccessToken,
              let baseUrl = URL(string: UserDefaults.standard.baseUrl)
        else { return }
        
        readLogin()
        
        Task {
            do {
                let result = try await ProjectFactsAPI.readTickets(for: ticketDate, using: userAccessToken, on: baseUrl)
                
                DispatchQueue.main.async {
                    self.pfTicketTimes = result
                    self.totalDuration = result.reduce(into: TimeInterval(0), { $0 += $1.duration }) * 60
                    self.totalBillableDuration = result.reduce(into: TimeInterval(0), { $0 += $1.billableDuration }) * 60
                    self.updateTimeStrings()
                }
            } catch {
                let errorMessage = (error as! ProjectFactsAPI.Errors).description
                logger.error("\(errorMessage)")
                
                DispatchQueue.main.async {
                    self.pfTicketTimes = []
                    self.totalDuration = 0
                    self.totalBillableDuration = 0
                    self.updateTimeStrings()
                    self.alertMessage = errorMessage
                }
            }
        }
    }
    
    /// This function will set the picked day to today and read all the tickets
    func readToday() {
        ticketDate = Date.now
        readTimes()
    }
    
    
}


// MARK: - Preview data

extension AppController {
    static let preview: AppController = {
        let controller = AppController(usePreviewData: true)
        //presentLoginForm = true
        
        controller.ticketDate = DateComponents(calendar: .current, year: 2022, month: 03, day: 03).date!
        
        controller.loginDate = DateComponents(calendar: .current, year: 2022, month: 03, day: 03, hour: 8, minute: 24).date!
        controller.logoutDate = DateComponents(calendar: .current, year: 2022, month: 03, day: 03, hour: 17, minute: 24).date!
        controller.sumBreak = 60
        
        
        controller.pfTicketTimes = [
            PFTimeEntry(id: 1, duration: 60, billableDuration: 45, description: "This is a test item entry"),
            PFTimeEntry(id: 2, duration: 22, billableDuration: 22, description: "Here is some description"),
            PFTimeEntry(id: 3, duration: 45, billableDuration: 45, description: "Dev. new awesome SwiftUI app")
        ]
        
        controller.totalDuration = controller.pfTicketTimes.reduce(into: TimeInterval(0), { $0 += $1.duration }) * 60
        controller.totalBillableDuration = controller.pfTicketTimes.reduce(into: TimeInterval(0), { $0 += $1.billableDuration }) * 60
        
        controller.updateTimeStrings()
        
        return controller
    }()
}
