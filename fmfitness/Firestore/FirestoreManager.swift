//
//  FirestoreManager.swift
//  fmfitness
//
//  Created by Brian Tacderan on 2/4/22.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import Combine

final class FirestoreManager: ObservableObject {

    static var shared = FirestoreManager()
    
    let didChange = PassthroughSubject<FirestoreManager, Never>()
    let willChange = PassthroughSubject<FirestoreManager, Never>()
    
    var activeAppts: [TodoItem] {
        activeApptIds.compactMap { appts[$0] }
    }
    
    var activeCount: Int {
        activeApptIds.count
    }

    /// Returns an ordered array of completed `TodoItem`s.
    var confirmedAppts: [TodoItem] {
        confirmedApptIds.compactMap { appts[$0] }
    }

    /// Returns the total number of completed `TodoItem`s.
    var confirmedCount: Int {
        confirmedApptIds.count
    }
    
    /// Returns an ordered array of completed `TodoItem`s.
    var completedAppts: [TodoItem] {
        completedApptIds.compactMap { appts[$0] }
    }

    /// Returns the total number of completed `TodoItem`s.
    var completedCount: Int {
        completedApptIds.count
    }
    
    /// Returns an ordered array of completed `TodoItem`s.
    var canceledAppts: [TodoItem] {
        canceledApptIds.compactMap { appts[$0] }
    }

    /// Returns the total number of completed `TodoItem`s.
    var canceledCount: Int {
        canceledApptIds.count
    }
    
    var isFresh = true
    
    /// The unique id used for each item created within the list.
    var nextId: Int = 0
   
    @Published var appts: [Int: TodoItem] = [:] {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var appointment: Appointment = Appointment.default {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var focusAppt: Appointment = Appointment.default {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }

    @Published var appointments: [Appointment] = [] {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var activeApptIds: [Int] = [] {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var confirmedApptIds: [Int] = [] {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }

    @Published var completedApptIds: [Int] = [] {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var canceledApptIds: [Int] = [] {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    /// The unique id used for each item created within the list of `users`.
    var nextUserId: Int = 0
    
    /// The data source of `User` instances within a dictionary set.
    @Published var users: [Int: User] = [:] {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }

    /// The data source of `User` instances within a list.
    @Published var allUsers: [User] = [] {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    var activeUsers: [User] {
        activeApptIds.compactMap { users[$0] }
    }
    
    var activeUserCount: Int {
        activeApptIds.count
    }
    
    var potentialUsers: [User] {
        confirmedApptIds.compactMap { users[$0] }
    }

    var potentialUserCount: Int {
        confirmedApptIds.count
    }
    
    /// An ordered array of item identifiers that make up the `User`'s to be shown in the 'Unconfirmed' section.
    @Published var activeUserIds: [Int] = [] {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    /// An ordered array of item identifiers that make up the `User`'s to be shown in the 'Confirmed' section.
    @Published var potentialUserIds: [Int] = [] {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var profile: Profile = Profile.default {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var user: Profile = Profile.default {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var currentPage: Dashboard = .startPage {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var isLoggedIn = false {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var showProfile = false {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var showSidebar = false {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var showRegister = false {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var sort: Int = 3 {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var firstLogin = false {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var induceShade = false {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var apptChanges: [TodoItem] = [] {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var selection: Tab = .home {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var authRedirect: Page = .loginPage {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
}
