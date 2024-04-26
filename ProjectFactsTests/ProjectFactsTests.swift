//
//  ProjectFactsTests.swift
//  ProjectFactsTests
//
//  Created by Andre Albach on 23.04.24.
//

import XCTest
@testable import ProjectFacts

final class ProjectFactsTests: XCTestCase {
    
    private let baseUrl = URL(string: "https://projectfacts.de")!
    private let accessToken = ""
    private let accessId = 12345
    private let userId = 12345
    private let ticketId = 12345
    
    private var userAccessToken: (userId: Int, tokenId: Int, token: String) {
        get { (userId: userId, tokenId: accessId, token: accessToken) }
    }
    
    private let date = Calendar.current.date(from: DateComponents(year: 2024, month: 4, day: 23))!
    

    func test_apiEndpoints() async {
        do {
            /// List all the endpoints
            let endpoints = try await ProjectFactsAPI.apiDescription(using: userAccessToken, on: baseUrl)
            print(endpoints.map(\.caption).joined(separator: "\n"))
            
        } catch {
            if let error = error as? ProjectFactsAPI.Errors {
                print(error.description)
            } else {
                print(error)
            }
        }
    }
    
    func test_loginTime() async {
        do {
            if let loginTime = try await ProjectFactsAPI.loginTime(for: date, using: userAccessToken, on: baseUrl) {
                print(loginTime)
            }
            
        } catch {
            if let error = error as? ProjectFactsAPI.Errors {
                print(error.description)
            } else {
                print(error)
            }
        }
    }
    
    func test_tickets() async {
        do {
            let tickets = try await ProjectFactsAPI.readTickets(for: date, using: userAccessToken, on: baseUrl)
            print(tickets)
            
            let ticketDescription = try await ProjectFactsAPI.readTicketDescription(for: ticketId, using: userAccessToken, on: baseUrl)
            print(ticketDescription)
            
        } catch {
            if let error = error as? ProjectFactsAPI.Errors {
                print(error.description)
            } else {
                print(error)
            }
        }
    }
}
