//
//  FirestoreManager.swift
//  fmfitness
//
//  Created by Brian Tacderan on 2/4/22.
//

import Firebase
import FirebaseFirestore
import Combine

final class FirestoreManager: ObservableObject {

    static var shared = FirestoreManager()
    
    let didChange = PassthroughSubject<FirestoreManager, Never>()
    let willChange = PassthroughSubject<FirestoreManager, Never>()
    
    let dateFormatter = DateFormatter()
    
    func next(newPage: Page) {
        if newPage == .loginPage {
            self.isLoggedIn = false
        }
        self.currentPage = newPage
        self.showingProfile = false
    }
    
    func login(email: String) {
        self.isLoggedIn = true
        self.fetchProfile(email: email)
        self.currentPage = .homePage
    }
    
    func fetchProfile(email: String) {
        
        let dataLoader = FirestoreLoader()
        let db = Firestore.firestore()
        let settings = db.settings
        // settings.isPersistenceEnabled = false
        db.settings = settings
        
        let docRef = db.collection("profiles").document(email)

        docRef.getDocument { (document, error) in
            guard error == nil else {
                print("error", error ?? "")
                return
            }

            if let document = document, document.exists {
                var dateVal: Date
                var dateStrAppt: String
                
                self.dateFormatter.dateFormat = "dd/MM/yy"
                self.dateFormatter.dateStyle = .medium
                self.dateFormatter.timeStyle = .short
                
                let data = document.data()
                if let data = data {
                    let dataEmail = data["email"]as? String ?? email
                    let dataAdmin = data["isAdmin"]as? Bool ?? false
                    let dataUser = data["username"]as? String ?? email.components(separatedBy: "@")[0]
                    let dataPrefer = data["prefersNotifications"]as? Bool ?? true
                    let dataSeason = data["seasonalPhoto"]as? String ?? "☃️"
                       
                    if let dataAppt = data["nextAppointment"]as? Timestamp {
                        dateVal = dataAppt.dateValue()
                        dateStrAppt = self.dateFormatter.string(from: dateVal)
                    } else {
                        dateStrAppt = self.dateFormatter.string(from: Date())
                    }
                    
                    self.profile.email = dataEmail
                    self.profile.isAdmin = dataAdmin
                    self.profile._username = dataUser
                    self.profile.prefersNotifications = dataPrefer
                    self.profile.seasonalPhoto = dataSeason
                    self.profile.nextAppointment = self.dateFormatter.date(from: dateStrAppt)!
                    
                }
            } else {
                self.setProfile(email: email, isAdmin: false, prefersNotifications: true, seasonalPhoto: "☃️", nextAppointment: Date(), username: email.components(separatedBy: "@")[0])
                self.fetchProfile(email: email)
                return
            }
        }
        allowDataflow(loader: dataLoader)
    }
    
    func setProfile(email: String, isAdmin: Bool, prefersNotifications: Bool, seasonalPhoto: String, nextAppointment: Date, username: String?) {
        
        let db = Firestore.firestore()
        
        if username != nil {
            // Add a new document or update a document in collection "profiles"
            db.collection("profiles").document(email).setData([
                "email": email,
                "isAdmin": isAdmin,
                "prefersNotifications": prefersNotifications,
                "seasonalPhoto": seasonalPhoto,
                "nextAppointment": nextAppointment,
                "username": username!
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
        } else {
            // Add a new document or update a document in collection "profiles"
            db.collection("profiles").document(email).setData([
                "email": email,
                "prefersNotifications": prefersNotifications,
                "seasonalPhoto": seasonalPhoto,
                "nextAppointment": nextAppointment
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
        }
    }
    
    func setTraining(timeslot: Date, email: String) {
        
        let db = Firestore.firestore()
        
        let docRefAppt = db.collection("appointments").document("\(email.components(separatedBy: "@")[0])_appointment")
    
        docRefAppt.setData([
            "isConfirmed": false,
            "nextAppointment": timeslot
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        let docRefTwo = db.collection("profiles").document(email)
        
        docRefTwo.setData(["nextAppointment": timeslot], merge: true) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    private var cancellable: AnyCancellable?
    
    private func allowDataflow(loader: FirestoreLoader) {
        loader.profilePublisher { publisher in
            self.cancellable = publisher.sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error retrieving profile: \(error)")
                }
            } receiveValue: { profile in
                self.profile = profile
            }
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
    
    @Published var currentPage: Page = .welcomePage {
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
    
    @Published var menuShow = false {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var showingProfile = false {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
}
