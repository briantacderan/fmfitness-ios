//
//  Profile.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/18/22.
//

import Foundation
import Combine
import SwiftUI
import GoogleSignIn

struct Profile: Decodable {
    
    var uid: String = ""
    var email: String = ""
    var isAdmin: Bool = false
    var isMember: Bool = false
    var userInfo: String = "new"
    var currentLevel: String = Level.nine.rawValue
    var outstandingBalance: Int = 0
    var nextAppointment: Date = Date()
    var focusTarget: String = Focus.tb.rawValue
    
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
    
    static var `default`: Profile = Profile(uid: "abc123",
                                            email: "new_profile@email.com",
                                            isAdmin: true,
                                            isMember: false,
                                            userInfo: "new",
                                            currentLevel: Level.nine.rawValue,
                                            outstandingBalance: 0,
                                            nextAppointment: Date(),
                                            focusTarget: Focus.tb.rawValue,
                                            _username: "new_profile"
    )

    enum Level: String, CaseIterable, Identifiable {
        case one = "😷"
        case three = "😵"
        case five = "😮‍💨"
        case seven = "😕"
        case eight = "🙂"
        case nine = "😁"
        case readyOne = "💪🏾"
        case readyTwo = "💪🏼"

        var id: String { rawValue }
    }
    
    enum Focus: String, CaseIterable, Identifiable {
        case cb = "chest-back"
        case lb = "legs-back"
        case sa = "shoulders-arms"
        case bb = "back-biceps"
        case ct = "chest-triceps"
        case tb = "total-body"

        var id: String { rawValue }
    }
}

extension Profile {
    
    enum CodingKeys: String, CodingKey {
        case uid
        case email
        case isAdmin
        case isMember
        case userInfo
        case currentLevel
        case outstandingBalance
        case nextAppointment
        case focusTarget
        case _username = "username"
    }

    static func createFromJSON(_ data: Data) -> Profile {
        let f = try? JSONDecoder().decode(Profile.self, from: data)
        // f.finalizeInit()
        return f!
    }

    init(from decoder: Decoder, uid: String, email: String, isAdmin: Bool, isMember: Bool, userInfo: String, currentLevel: String, outstandingBalance: Int, nextAppointment: Date, focusTarget: String, username: String) throws {
        // let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uid = uid
        self.email = email
        self.isAdmin = isAdmin
        self.isMember = isMember
        self.userInfo = userInfo
        self.currentLevel = currentLevel
        self.outstandingBalance = outstandingBalance
        self.nextAppointment = nextAppointment
        self.focusTarget = focusTarget
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
