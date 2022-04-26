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
    
    let dateFormatter = DateFormatter()
    
    func next(newPage: Page) {
        if newPage == .loginPage {
            self.isLoggedIn = false
            self.profile = Profile.default
        } 
        self.showingProfile = false
        withAnimation {
            self.currentPage = newPage
        }
    }
    
    func login(email: String) {
        self.isLoggedIn = true
        self.fetchProfile(email: email)
        self.fetchTraining()
        withAnimation {
            self.currentPage = .homePage
        }
    }
    
    func fetchProfile(email: String) {
        
        //let dataLoader = FirestoreLoader()
        //dataLoader.email = email
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
                    let dataConnect = data["stripeConnected"]as? Bool ?? false
                    let dataLevel = data["currentLevel"]as? String ?? Profile.Level.nine.rawValue
                    let dataBalance = data["outstandingBalance"]as? Int ?? 0
                    let dataStripe = data["stripeID"]as? String ?? "new"
                    let dataFocus = data["focusTarget"]as? String ?? Profile.Focus.tb.rawValue
                    
                    if let dataAppt = data["nextAppointment"]as? Timestamp {
                        dateVal = dataAppt.dateValue()
                        dateStrAppt = self.dateFormatter.string(from: dateVal)
                    } else {
                        dateStrAppt = self.dateFormatter.string(from: Date())
                    }
                    
                    self.profile.email = dataEmail
                    self.profile.isAdmin = dataAdmin
                    self.profile._username = dataUser
                    self.profile.stripeConnected = dataConnect
                    self.profile.currentLevel = dataLevel
                    self.profile.outstandingBalance = dataBalance
                    self.profile.stripeID = dataStripe
                    self.profile.focusTarget = dataFocus
                    self.profile.nextAppointment = self.dateFormatter.date(from: dateStrAppt)!
                }
            } else {
                self.setProfile(parameters: ["email": email, "isAdmin": false, "stripeConnected": false, "currentLevel": Profile.Level.nine.rawValue, "outstandingBalance": 0, "stripeID": "new", "nextAppointment": Date(), "focusTarget": Profile.Focus.tb.rawValue, "username": email.components(separatedBy: "@")[0]])
                self.fetchProfile(email: email)
            }
        }
        //allowDataflow(loader: dataLoader)
        //dataLoader.email = ""
    }
    
    func setProfile(parameters: [String: Any?]) {
        
        let db = Firestore.firestore()
        let email = parameters["email"]as? String ?? self.profile.email
        
        let params: [String: Any?] = [
            "email": email,
            "isAdmin": parameters["isAdmin"]as? Bool ?? self.profile.isAdmin,
            "striped": parameters["striped"]as? Bool ?? self.profile.stripeConnected,
            "currentLevel": parameters["currentLevel"]as? String ?? self.profile.currentLevel,
            "outstandingBalance": parameters["outstandingBalance"]as? Int ?? self.profile.outstandingBalance,
            "timeslot": parameters["timeslot"]as? Date ?? self.profile.nextAppointment,
            "acctNum": parameters["acctNum"]as? String ?? self.profile.stripeID,
            "focusTarget": parameters["focusTarget"]as? String ?? self.profile.focusTarget,
            "username": parameters["username"]as? String ?? self.profile._username
        ]
        
        // Add a new document or update a document in collection "profiles"
        db.collection("profiles").document(email).setData([
            "email": params["email"]!!,
            "isAdmin": params["isAdmin"]!!,
            "stripeConnected": params["striped"]!!,
            "currentLevel": params["currentLevel"]!!,
            "outstandingBalance": params["outstandingBalance"]!!,
            "nextAppointment": params["timeslot"]!!,
            "stripeID": params["acctNum"]!!,
            "focusTarget": params["focusTarget"]!!,
            "username": params["username"]!!
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func fetchTraining() {
        
        self.appts = [:]
        self.appointments = []
        self.nextId = 0
        self.activeApptIds = []
        self.confirmedApptIds = []
        self.completedApptIds = []
        self.paidApptIds = []
        
        //let dataLoader = FirestoreLoader()
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        
        let docRef = db.collection("appointments")

        docRef.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                print("error", error ?? "")
                return
            }
            
            self.dateFormatter.dateFormat = "dd/MM/yy"
            self.dateFormatter.dateStyle = .medium
            self.dateFormatter.timeStyle = .short
            
            print("Number of documents: \(snapshot.documents.count)")
            
            self.appointments = snapshot.documents.compactMap { docSnap in
                var dateStrAppt: String
                
                let docData = docSnap.data()
                let id = self.nextId
                let email = docData["email"] as? String ?? ""
                let invo = docData["invoice"] as? String ?? ""
                let confirm = docData["isConfirmed"] as? Bool ?? false
                let complete = docData["isCompleted"] as? Bool ?? false
                let paid = docData["isPaid"] as? Bool ?? false
                
                if let dataAppt = docData["nextAppointment"]as? Timestamp {
                    let dateVal = dataAppt.dateValue()
                    dateStrAppt = self.dateFormatter.string(from: dateVal)
                } else {
                    dateStrAppt = self.dateFormatter.string(from: Date())
                }
                
                let appointment = Appointment(id: id, email: email, invoice: invo, isConfirmed: confirm, isCompleted: complete, isPaid: paid, nextAppointment: self.dateFormatter.date(from: dateStrAppt)!)
                
                self.addAppt(withEmail: email, invoice: invo, isConfirmed: confirm, isCompleted: complete, isPaid: paid, nextAppointment: self.dateFormatter.date(from: dateStrAppt)!)
                
                return appointment
            }
        }
        //allowDataflowAppt(loader: dataLoader)
    }
    
    func setTraining(parameters: [String: Any?]) {
        
        let db = Firestore.firestore()
        let email = parameters["email"]as? String ?? self.profile.email
        
        let params: [String: Any?] = [
            "email": email,
            "invoice": parameters["invoice"]as? String ?? "",
            "isConfirmed": parameters["isConfirmed"]as? Bool ?? false,
            "isCompleted": parameters["isCompleted"]as? Bool ?? false,
            "isPaid": parameters["isPaid"]as? Bool ?? false,
            "timeslot": parameters["timeslot"]as? Date ?? self.profile.nextAppointment
        ]
        
        let docRefAppt = db.collection("appointments").document("\(email.components(separatedBy: "@")[0])_appointment")
    
        docRefAppt.setData([
            "email": params["email"]!!,
            "invoice": params["invoice"]!!,
            "isConfirmed": params["isConfirmed"]!!,
            "isCompleted": params["isCompleted"]!!,
            "isPaid": params["isPaid"]!!,
            "nextAppointment": params["timeslot"]!!
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        let docRefTwo = db.collection("profiles").document(email)
        
        docRefTwo.setData(["nextAppointment": params["timeslot"]!!], merge: true) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    
        self.fetchTraining()
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
    
    private var cancellableAppt: AnyCancellable?
    
    private func allowDataflowAppt(loader: FirestoreLoader) {
        loader.appointmentPublisher { publisher in
            self.cancellableAppt = publisher.sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error retrieving appointment: \(error)")
                }
            } receiveValue: { appointment in
                self.appointment = appointment
            }
        }
    }
                  
    /// Inserts a new `Appointment` into the list with the given details.
    func addAppt(withEmail email: String, invoice: String, isConfirmed: Bool, isCompleted: Bool, isPaid: Bool, nextAppointment: Date) {
        let id = nextId
        nextId += 1

        appts[id] = AdminData(id: id, email: email, invoice: invoice, isConfirmed: isConfirmed, isCompleted: isCompleted, isPaid: isPaid, nextAppointment: nextAppointment)
            
        if isPaid {
            paidApptIds.append(id)
        } else if isCompleted {
            completedApptIds.append(id)
        } else if isConfirmed {
            confirmedApptIds.append(id)
        } else {
            activeApptIds.append(id)
        }
    }

    /// Updates the `isCompleted` property for a `TodoItem` held within the receiver with the given identifier.
    /// Toggling the value via this method will also ensure that the Todo is moved to the appropriate list of items.
    func updateAppt(withId id: Int, isConfirmed: Bool, isCompleted: Bool, isPaid: Bool) {
        guard
            let appt = appts[id],
            appt.isConfirmed != isConfirmed || appt.isCompleted != isCompleted || appt.isPaid != isPaid
        else { return }
        
        activeApptIds.removeAll { $0 == id }
        confirmedApptIds.removeAll { $0 == id }
        completedApptIds.removeAll { $0 == id }
        paidApptIds.removeAll { $0 == id }

        if appt.isPaid != isPaid && isPaid == true {
            paidApptIds.append(id)
        } else if (appt.isPaid != isPaid && isPaid == false) || (appt.isCompleted != isCompleted && isCompleted == true) {
            completedApptIds.append(id)
        } else if (appt.isCompleted != isCompleted && isCompleted == false) || (appt.isConfirmed != isConfirmed && isConfirmed == true) {
            confirmedApptIds.append(id)
        } else {
            activeApptIds.append(id)
        }
        
        appt.isPaid = isPaid
        appt.isCompleted = isCompleted
        appt.isConfirmed = isConfirmed
        
        self.setTraining(parameters: ["email": appt.email, "isConfirmed": appt.isConfirmed, "isCompleted": appt.isCompleted, "isPaid": appt.isPaid])
    }

    func deleteActiveAppts(atOffsets offsets: IndexSet) {
        for index in offsets {
            appts.removeValue(forKey: activeApptIds[index])
        }

        activeApptIds.remove(atOffsets: offsets)
    }

    func moveActiveAppts(fromOffsets source: IndexSet, toOffset destination: Int) {
        activeApptIds.move(fromOffsets: source, toOffset: destination)
    }

    /// Returns an instance of `TodoList` that is pre-populated with sample data.
    static func sampleData() {
        @ObservedObject var shared = FirestoreManager.shared

        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today.addingTimeInterval(60 * 60 * 24)

        shared.addAppt(withEmail: "email_one@sample.com", invoice: "", isConfirmed: false, isCompleted: false, isPaid: false, nextAppointment: tomorrow)
        shared.addAppt(withEmail: "email_two@sample.com", invoice: "", isConfirmed: false, isCompleted: false, isPaid: false, nextAppointment: tomorrow)
        shared.addAppt(withEmail: "email_tree@sample.com", invoice: "", isConfirmed: false, isCompleted: true, isPaid: false, nextAppointment: tomorrow)
    }
    
    var activeAppts: [AdminData] {
        activeApptIds.compactMap { appts[$0] }
    }
    
    var activeCount: Int {
        activeApptIds.count
    }

    /// Returns an ordered array of completed `AdminData`s.
    var confirmedAppts: [AdminData] {
        confirmedApptIds.compactMap { appts[$0] }
    }

    /// Returns the total number of completed `TodoItem`s.
    var confirmedCount: Int {
        confirmedApptIds.count
    }
    
    /// Returns an ordered array of completed `AdminData`s.
    var completedAppts: [AdminData] {
        completedApptIds.compactMap { appts[$0] }
    }

    /// Returns the total number of completed `TodoItem`s.
    var completedCount: Int {
        completedApptIds.count
    }
    
    /// Returns an ordered array of completed `AdminData`s.
    var paidAppts: [AdminData] {
        paidApptIds.compactMap { appts[$0] }
    }

    /// Returns the total number of completed `TodoItem`s.
    var paidCount: Int {
        paidApptIds.count
    }
    
    /// The unique id used for each item created within the list.
    private var nextId: Int = 0
   
    @Published var appts: [Int: AdminData] = [:] {
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

    /// The data source of `TodoItem` instances within the list.
    @Published var appointments: [Appointment] = [] {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    

    /// An ordered array of item identifiers that make up the `TodoItem`'s to be shown in the 'Unconfirmed' section.
    @Published private var activeApptIds: [Int] = [] {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    /// An ordered array of item identifiers that make up the `AdminData`'s to be shown in the 'Confirmed' section.
    @Published private var confirmedApptIds: [Int] = [] {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }

    /// An ordered array of item identifiers that make up the `AdminData`'s to be shown in the 'Completed' section.
    @Published private var completedApptIds: [Int] = [] {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    /// An ordered array of item identifiers that make up the `AdminData`'s to be shown in the 'Paid' section.
    @Published private var paidApptIds: [Int] = [] {
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
    
    @Published var editMode = false {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var sort = 3 {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
    
    @Published var blurSecure: CGFloat = 0 {
        didSet {
            didChange.send(self)
        }
        willSet {
            willChange.send(self)
        }
    }
}
