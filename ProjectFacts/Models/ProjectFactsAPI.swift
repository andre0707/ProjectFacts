//
//  ProjectFactsAPI.swift
//  ProjectFacts
//
//  Created by Andre Albach on 03.03.22.
//

import Foundation
import RegexBuilder

// Check: https://docs.google.com/presentation/d/1rsZav2HonLQyCSyavgEOrSNYUE7SGFIEj9epVH5R4is/edit#slide=id.g2104f6f7d9_0_4
// JSON-Representants as Typescript-Classes : https://sync.projectfacts.de/api/api/dto.ts


/// Namespace for the API calls
enum ProjectFactsAPI {
    
    /// The complete access token information
    typealias UserAccessToken = (userId: Int, tokenId: Int, token: String)
    /// The complete attendance for a day
    typealias DayAttendance = (begin: Date, end: Date?, sumBreak: TimeInterval)
    
    
    // MARK: - Errors
    
    /// Errors which can occour with this api
    enum Errors: Error, CustomStringConvertible, CustomDebugStringConvertible {
        case invalidCredentials
        case invalidLogin
        case invalidURL
        case invalidResponse
        case connectionError(HTTPURLResponse)
        case decodingError(Error)
        
        var description: String {
            switch self {
            case .invalidCredentials:
                return "invalidCredentials"
            case .invalidLogin:
                return "invalidLogin"
            case .invalidURL:
                return "invalidURL"
            case .invalidResponse:
                return "invalidResponse"
            case .connectionError(let hTTPURLResponse):
                return "connectionError: \(hTTPURLResponse.statusCode) \(hTTPURLResponse.description)"
            case .decodingError(let error):
                return "decodingError: \(error.localizedDescription)"
            }
        }
        var debugDescription: String { description }
    }
    
    
    // MARK: - Endpoints
    
    /// A list of the endpoints
    private enum Endpoint {
        static let api = "/api/api"
        static let attendance = "/api/attendance"
        static let attendancecategory = "/api/attendancecategory"
        static let bookmark = "/api/bookmark"
        static let cancellation = "/api/cancellation"
        static let cancellationposition = "/api/cancellationposition"
        static let chatgroup = "/api/chatgroup"
        static let chatmessage = "/api/chatmessage"
        static let cico = "/api/cico"
        static let colorlabel = "/api/colorlabel"
        static let contact = "/api/contact"
        static let contactfield = "/api/contactfield"
        static let contract = "/api/contract"
        static let contractposition = "/api/contractposition"
        static let correctiveinvoice = "/api/correctiveinvoice"
        static let correctiveinvoiceposition = "/api/correctiveinvoiceposition"
        static let creditnote = "/api/creditnote"
        static let creditnoteposition = "/api/creditnoteposition"
        static let crmactivity = "/api/crmactivity"
        static let currency = "/api/currency"
        static let day = "/api/day"
        static let device = "/api/device"
        static let `enum` = "/api/enum"
        static let expense = "/api/expense"
        static let file = "/api/file"
        static let financepositiongroup = "/api/financepositiongroup"
        static let interface = "/api/interface"
        static let invoice = "/api/invoice"
        static let invoiceposition = "/api/invoiceposition"
        static let notification = "/api/notification"
        static let offer = "/api/offer"
        static let offerposition = "/api/offerposition"
        static let organization = "/api/organization"
        static let project = "/api/project"
        static let projectfolder = "/api/projectfolder"
        static let projecthistory = "/api/projecthistory"
        static let testaccount = "/api/testaccount"
        static let ticket = "/api/ticket"
        static let ticketchannel = "/api/ticketchannel"
        static let ticketprocess = "/api/ticketprocess"
        static let ticketstate = "/api/ticketstate"
        static let time = "/api/time"
        static let timecategory = "/api/timecategory"
        static let timetemplate = "/api/timetemplate"
        static let travelexpenses = "/api/travelexpenses"
        static let user = "/api/user"
        static let vacationrequest = "/api/vacationrequest"
    }
    
    
    /// Use this function to create a URLRequest which will add the access information to the header of the request
    /// - Parameters:
    ///   - url: The url
    ///   - accessToken: The access token information
    /// - Returns: The resulting URLRequest
    private static func urlRequest(for url: URL, using accessToken: UserAccessToken) throws -> URLRequest {
        guard let base64Credentials = "\(accessToken.tokenId):\(accessToken.token)".data(using: .utf8)?.base64EncodedString() else { throw Errors.invalidCredentials }
        
        var request = URLRequest(url: url)
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    /// A simple structure for response items
    private struct ResponseItem: Codable {
        let caption: String
        let title: String
        let href: String
        let lastModifiedDate: String
        let value: Int
        let idKey: String
        let rel: String
    }
    
    
    // MARK: - API description
    
    /// A simple helper structure for api description item
    struct ApiEndpointDescription: Codable {
        let caption: String
        let href: String
    }
    
    private struct ApiEndpointDescriptionResponse: Codable {
        let items: [ApiEndpointDescription]
    }
    
    /// Will return the enpoints of the api
    /// - Parameters:
    ///   - accessToken: The access token to use
    ///   - baseUrl: The base url
    /// - Returns: The list of endpoints
    static func apiDescription(using accessToken: UserAccessToken, on baseUrl: URL) async throws -> [ApiEndpointDescription] {
        let url = baseUrl.baseURL?.appendingPathComponent(Endpoint.api) ?? baseUrl.appendingPathComponent(Endpoint.api)
        
        let request = try urlRequest(for: url, using: accessToken)
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
            guard let httpResponse = urlResponse as? HTTPURLResponse else { throw Errors.invalidResponse }
            guard httpResponse.statusCode == 200 else { throw Errors.connectionError(httpResponse)}
                        
            return try JSONDecoder().decode(ApiEndpointDescriptionResponse.self, from: data).items
            
        } catch {
            throw Errors.decodingError(error)
        }
    }
    
    
    // MARK: - Access token
    
    /// A structure representing a `Endpoint.device` response
    private struct LoginAuthentication: Codable {
        let email: String
        let password: String
        let deviceName: String
        let deviceType: String
    }
    
    /// A structure which represents an answer of an `LoginAuthentication` request
    private struct LoginResponse: Codable {
        let _url: String?
        let _id: Int
        let _idKey: String?
        let deviceName: String?
        let deviceType: String?
        let token: String
        let apiHost: String?
        let externalAccess: Bool?
        let user: User
        
        struct User: Codable {
            let caption: String?
            let title: String?
            let href: String?
            let value: Int
            let idKey: String?
        }
    }
    
    /// Use this function to create an access token
    /// - Parameters:
    ///   - emailAddress: The user email to use to create the access token
    ///   - password: The user password to use to create the access token.
    ///   - baseUrl: The base url of the project facts API
    /// - Returns: (id, token) if `emailAddress` and `password` were valid
    static func createAccessToken(with emailAddress: String, and password: String, on baseUrl: URL) async throws -> UserAccessToken {
        /// Check if credentials are filled
        guard !emailAddress.isEmpty,
              !password.isEmpty
        else { throw Errors.invalidCredentials }
        
        let url = baseUrl.baseURL?.appendingPathComponent(Endpoint.device) ?? baseUrl.appendingPathComponent(Endpoint.device)
                
        /// Create login object and convert it to JSON
        let login = LoginAuthentication(email: emailAddress,
                                        password: password,
                                        deviceName: "PFOnMacOS",
                                        deviceType: "de.fivepoint.other")
        let jsonData = try! JSONEncoder().encode(login)
        
        /// Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else { throw Errors.invalidResponse }
            guard httpResponse.statusCode == 200 else { throw Errors.connectionError(httpResponse)}
            
            let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
            
            return (userId: loginResponse.user.value, tokenId: loginResponse._id, token: loginResponse.token)
        } catch {
            throw Errors.decodingError(error)
        }
    }
    
    
    // MARK: - Read Login
    
    /// A structure representing a `Endpoint.day` response
    private struct DaysResponse: Codable {
        let items: [ResponseItem]
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<ProjectFactsAPI.DaysResponse.CodingKeys> = try decoder.container(keyedBy: ProjectFactsAPI.DaysResponse.CodingKeys.self)
            self.items = try container.decodeIfPresent([ProjectFactsAPI.ResponseItem].self, forKey: ProjectFactsAPI.DaysResponse.CodingKeys.items) ?? []
        }
    }
    
    /// A structure representing a single item from a `Endpoints.day` request
    private struct DayResponse: Codable {
        let begin: String
        let end: String?
        let sumBreak: Int /// Minutes
    }
    
    /// This function will read the login information for the provided `date`
    /// - Parameters:
    ///   - date: The date for which the login information are needed
    ///   - accessToken: The access token structure
    ///   - baseUrl: The base url to use
    /// - Returns: The resulting login information for `date`
    static func loginTime(for date: Date, using accessToken: UserAccessToken, on baseUrl: URL) async throws -> DayAttendance? {
        let formattedDate = DateFormatter.pfCompatible.string(from: date)
        
        let endpointUrl = baseUrl.baseURL?.appendingPathComponent(Endpoint.day) ?? baseUrl.appendingPathComponent(Endpoint.day)
        
        guard var components = URLComponents(url: endpointUrl, resolvingAgainstBaseURL: false) else { throw Errors.invalidURL }
        components.queryItems = [
            URLQueryItem(name: "date", value: formattedDate),
            URLQueryItem(name: "worker", value: "\(accessToken.userId)" )
        ]
        
        guard let url = components.url else { throw Errors.invalidURL }
        let request = try urlRequest(for: url, using: accessToken)
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
            guard let httpResponse = urlResponse as? HTTPURLResponse else { throw Errors.invalidResponse }
            guard httpResponse.statusCode == 200 else { throw Errors.connectionError(httpResponse)}
                        
            guard let dayId = (try JSONDecoder().decode(DaysResponse.self, from: data)).items.first?.value else { throw Errors.invalidLogin }
            
            let dayRequest = try urlRequest(for: endpointUrl.appendingPathComponent("\(dayId)"), using: accessToken)
            let (dayData, dayResponse) = try await URLSession.shared.data(for: dayRequest, delegate: nil)
                        
            guard let httpResponse = dayResponse as? HTTPURLResponse else { throw Errors.invalidResponse }
            guard httpResponse.statusCode == 200 else { throw Errors.invalidResponse }
            
            let dayObject: DayResponse
            do {
                dayObject = try JSONDecoder().decode(DayResponse.self, from: dayData)
            } catch {
                print("No login information for this day")
                return nil
            }
            print(dayObject)
                        
            let formatter = DateFormatter.iso8601Full
            guard let beginDate = formatter.date(from: dayObject.begin) else { throw Errors.invalidLogin }
            let endDate: Date?
            if let end = dayObject.end {
                endDate = formatter.date(from: end)
            } else {
                endDate = nil
            }
            
            return (begin: beginDate, end: endDate, sumBreak: TimeInterval(dayObject.sumBreak))
        } catch {
            throw Errors.decodingError(error)
        }
    }
    
    
    // MARK: - Read Ticket Times
    
    /// A structure representing a `Endpoint.time` response
    private struct TimesResponse: Codable {
        let items: [ResponseItem]
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<ProjectFactsAPI.TimesResponse.CodingKeys> = try decoder.container(keyedBy: ProjectFactsAPI.TimesResponse.CodingKeys.self)
            self.items = try container.decodeIfPresent([ProjectFactsAPI.ResponseItem].self, forKey: ProjectFactsAPI.TimesResponse.CodingKeys.items) ?? []
        }
    }
    
    /// A structure representing a single item from a `Endpoints.time` request
    private struct TimeResponse: Codable {
        let amount: Int /// Minutes
        let amountBillable: Int /// Minuates
        let description: String
        let color: String?
        //let hourlyRateInternal: Double /// No longer available
        let hourlyRateExternal: Double
        let begin: String? /// Date representation in ISO8601
        let end: String? /// Date representation in ISO8601
        let referenceNumber: String?
        // let invoiceOptions: String? /// APILinkObject
        let date: String
        //let timetemplate: String? /// APILinkObject
        let ticket: TicketResponse?
        
        /// A structure representing a ticket response within a `TimeResponse`
        struct TicketResponse: Codable {
            let caption: String
            let title: String
            let href: String
            let value: Int
            let idKey: String
        }
        
        /// The id of the ticket, if the ticket is available
        var ticketId: Int? { ticket?.value }
    }
    
    /// This function will read the ticket time information for the provided `date`
    /// - Parameters:
    ///   - date: The date for which the login information are needed
    ///   - accessToken: The access token structure
    ///   - baseUrl: The base url to use
    /// - Returns: The resulting ticket time information for `date`
    static func readTickets(for date: Date, using accessToken: UserAccessToken, on baseUrl: URL) async throws -> [PFTimeEntry] {
        let formattedDate = DateFormatter.pfCompatible.string(from: date)
        
        let endpointUrl = baseUrl.baseURL?.appendingPathComponent(Endpoint.time) ?? baseUrl.appendingPathComponent(Endpoint.time)
        
        guard var components = URLComponents(url: endpointUrl, resolvingAgainstBaseURL: false) else { throw Errors.invalidURL }
        components.queryItems = [
            URLQueryItem(name: "date", value: formattedDate),
            URLQueryItem(name: "worker", value: "\(accessToken.userId)" )
        ]
        
        guard let url = components.url else { throw Errors.invalidURL }
        let request = try urlRequest(for: url, using: accessToken)
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
            guard let httpResponse = urlResponse as? HTTPURLResponse else { throw Errors.invalidResponse }
            guard httpResponse.statusCode == 200 else { throw Errors.connectionError(httpResponse)}
                        
            let timeIds = (try JSONDecoder().decode(TimesResponse.self, from: data)).items.map { $0.value }
            
            var result: [PFTimeEntry] = []
            
            for timeId in timeIds {
                let request = try urlRequest(for: endpointUrl.appendingPathComponent("\(timeId)"), using: accessToken)
                let (timeObjectData, response) = try await URLSession.shared.data(for: request, delegate: nil)
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("httpResponse error")
                    continue
                }
                guard httpResponse.statusCode == 200 else {
                    print("httpResponse error. Code: \(httpResponse.statusCode)")
                    continue
                }
                
                let timeObject = try JSONDecoder().decode(TimeResponse.self, from: timeObjectData)
                
                result.append(PFTimeEntry(id: timeId,
                                          duration: TimeInterval(timeObject.amount),
                                          billableDuration: TimeInterval(timeObject.amountBillable),
                                          description: timeObject.description,
                                          ticketId: timeObject.ticketId))
            }
            
            return result
        } catch {
            throw Errors.decodingError(error)
        }
    }
    
    
    // MARK: - Read tickets
    
    /// A structure representing a single item from a `Endpoints.ticket` request
    private struct TicketData: Codable {
        let ticketNumber: String
        let subject: String
        let description: String
    }
    
    /// Will read the ticket details of the ticket with `ticketId`
    /// - Parameters:
    ///   - ticketId: The id of the ticket which should be read
    ///   - accessToken: The access token structure
    ///   - baseUrl: The base url to use
    /// - Returns: The description of the ticket
    static func readTicketDescription(for ticketId: Int, using accessToken: UserAccessToken, on baseUrl: URL) async throws -> String {
        
        let endpointUrl = baseUrl.baseURL?.appendingPathComponent(Endpoint.ticket) ?? baseUrl.appendingPathComponent(Endpoint.ticket)
        
        let url = endpointUrl.appendingPathComponent("\(ticketId)")
        
        let request = try urlRequest(for: url, using: accessToken)
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request, delegate: nil)
            guard let httpResponse = urlResponse as? HTTPURLResponse else { throw Errors.invalidResponse }
            guard httpResponse.statusCode == 200 else { throw Errors.connectionError(httpResponse)}
                        
            let ticketData = try JSONDecoder().decode(TicketData.self, from: data)
            
            /// The images can not directly be displayed. So the idea is to extract the image links from the html description and download the images.
            /// The image links could then be replaced by a base64 version of the images. Another idea would be to cache the images in the temp directory.
            ///
            /// However, the download of the images does not seem to work so easily. Originally the images use `action=writeresp` in their url.
            /// In the browser it seems to be possible to download them with `action=download`. 
            /// But calling either of them via url request downloads only the login page and not the actual image
            /// There is probably a cookie or so missing.
            ///
            /// For now, reading tickets will not include the images in the description. This is why the following code is commented out and was used for testing purposes during development.
            
            /*
            // This will find all image tags inside the hmtl description.
            let imgSrc = Reference(Substring.self)
            let myRegexExpression = Regex {
                "<img"
                ZeroOrMore(.any, .reluctant)
                "src=\""
                Capture(ZeroOrMore(.any, .reluctant), as: imgSrc)
                "\""
                ZeroOrMore(.any, .reluctant)
                ">"
            }
            let results = ticketData.description.matches(of: myRegexExpression)
            let imageUrls = results.compactMap { URL(string: baseUrl.absoluteString + $0[imgSrc].replacingOccurrences(of: "&amp;", with: "&")) }
            for url in imageUrls {
                // Download all images and then display them in base64 mode or so
                
                let imageRequest = try urlRequest(for: URL(string: "https://aws.projectfacts.de/defaultFileIO.do?id=911.275388476&action=download")!, using: accessToken)
                let (imageData, _) = try await URLSession.shared.data(for: imageRequest, delegate: nil)
                
                /// For testing purposes we will try to write the file to the temp directory.
                print(imageData)
                print(URL.temporaryDirectory)
                try imageData.write(to: URL.temporaryDirectory.appendingPathComponent("image.jpg"))
                
                let imageRequest2 = try urlRequest(for: URL(string: "https://aws.projectfacts.de/defaultFileIO.do?id=911.275388476&action=writeresp")!, using: accessToken)
                let (imageData2, _) = try await URLSession.shared.data(for: imageRequest2, delegate: nil)
                
                /// For testing purposes we will try to write the file to the temp directory.
                print(imageData2)
                print(URL.temporaryDirectory)
                try imageData2.write(to: URL.temporaryDirectory.appendingPathComponent("image.jpg"))
            }
            */
            
            return ticketData.description
                .replacingOccurrences(of: #"src="/"#, with: "src=\"\(baseUrl.absoluteString)/")
                .replacingOccurrences(of: "&amp;", with: "&")
            
        } catch {
            throw Errors.decodingError(error)
        }
    }
}
