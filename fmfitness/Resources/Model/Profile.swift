//
//  Profile.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/18/22.
//

import Foundation


struct Profile: Decodable {
    
    var email: String
    var isAdmin = false
    var prefersNotifications = true
    var seasonalPhoto: String = ""
    var nextAppointment = Date()
    
    var _username: String?
    
    func getDefaultName() -> String {
        return email.components(separatedBy: "@")[0]
    }
        
    func username() -> String {
        let defaultName = getDefaultName()
        if _username != defaultName {
            return defaultName
        }
        return _username!
    }
    
    static var `default`: Profile = Profile(email: "new_profile@email.com",
                                            isAdmin: false,
                                            prefersNotifications: true,
                                            seasonalPhoto: Season.ready.rawValue,
                                            nextAppointment: Date(),
                                            _username: "new_profile"
    )

    enum Season: String, CaseIterable, Identifiable {
        case one = "😷"
        case three = "😵"
        case five = "😮‍💨"
        case seven = "😕"
        case eight = "🙂"
        case nine = "😁"
        case ready = "💪🏾"

        var id: String { rawValue }
    }
}

extension Profile {
    
    enum CodingKeys: String, CodingKey {
        case _username = "username"
        case email
        case isAdmin
        case nextAppointment
        case prefersNotifications
        case seasonalPhoto
    }

    static func createFromJSON(_ data: Data) -> Profile {
        let f = try? JSONDecoder().decode(Profile.self, from: data)
        // f.finalizeInit()
        return f!
    }

    init(from decoder: Decoder, email: String, isAdmin: Bool, username: String, prefersNotifications: Bool, seasonalPhoto: String, nextAppointment: Date) throws {
        // let container = try decoder.container(keyedBy: CodingKeys.self)
        self.prefersNotifications = prefersNotifications
        self.seasonalPhoto = seasonalPhoto
        self.nextAppointment = nextAppointment
        self.email = email
        self.isAdmin = isAdmin
        self._username = username
    }
}







/// A model type representing the response from the request for the current user's profile.
struct ProfileResponse: Decodable {
    
    /// The requested user's birthdays.
    let profile: Profile

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.profile = try container.decode(Profile.self, forKey: .profiles)
    }
}

extension ProfileResponse {
    enum CodingKeys: String, CodingKey {
        case profiles
    }
}

extension ProfileResponse {
    /// An error representing what may go wrong in processing the profile request.
    enum Error: Swift.Error {
        /// There was no profile in the returned results.
        case noProfileInResult
    }
}
