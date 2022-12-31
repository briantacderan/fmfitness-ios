//
//  PageController.swift
//  fm-fitness
//
//  Created by Brian Tacderan on 6/18/22.
//

import LocalAuthentication
import Combine
import SwiftUI
import Firebase
import FirebaseFirestore
import GoogleSignIn

enum BiometricType {
    case touchID
    case faceID
    case none
}

final class PageController: ObservableObject {
    static var shared = PageController()
    
    @ObservedObject var firestore = FirestoreManager.shared
    
    let context = LAContext()
    var reason = "Logging in with Biometric ID Authentication"
    
    /*
    private static var sharedPageController: PageController = {
        let controller = PageController()

        // Configuration
        // ...

        return controller
    }()
    
    /// The singleton object is accessible through the `shared()` class method.
    /// `PageController.shared()`
    class func shared() -> PageController {
        return sharedPageController
    }
    */
    
    private lazy var dateFormatter: DateFormatter? = {
        let df = DateFormatter()
        
        df.dateFormat = "dd/MM/yy"
        df.dateStyle = .medium
        df.timeStyle = .short
        
        return df
    }()
    
    private lazy var profile: Profile? = {
        return self.firestore.profile
    }()
    
    private lazy var focusAppt: Appointment? = {
        return self.firestore.focusAppt
    }()
    
    private func getProfileData(email: String, completion: @escaping ([String : Any]?) -> Void) {
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
    
        db.collection("profiles").document(email).getDocument { (document, error) in
            guard let document = document, document.exists else {
                print("No such document available")
                completion(nil)
                return
            }
            let data = document.data()
            completion(data)
        }
    }
    
    private func getUserApptData(doc: String, completion: @escaping ([String : Any]?) -> Void) {
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        
        var docData: [String : Any]?
        
        let docRef = db.collection("appointments")
            .whereField((doc.contains("@") ? "email" : "uid"), isEqualTo: doc)
            .order(by: "nextAppointment", descending: true)
            .limit(to: 1)

        docRef.getDocuments { (snapshot, error) in
            guard let docSnap = snapshot, error == nil else {
                print("error", error ?? "")
                completion(nil)
                return
            }
            docData = docSnap.documents[0].data()
            completion(docData)
        }
    }
    
    private func getDocuments(of model: String,
                              completion: @escaping ([QueryDocumentSnapshot]?) -> Void) {
        let db = Firestore.firestore()
        let settings = db.settings
        let docRef = db.collection(model)
        
        var docs: [QueryDocumentSnapshot] = []
        
        db.settings = settings

        docRef.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                print("error", error ?? "")
                completion(nil)
                return
            }
            docs = snapshot.documents
            print("Number of documents: \(docs.count)")
            completion(docs)
        }
    }
    
    func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
    }

    func biometricType() -> BiometricType {
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        switch context.biometryType {
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        default:
            return .none
        }
    }
    
    func authenticateUser(completion: @escaping (String?) -> Void) {
        guard canEvaluatePolicy() else {
            completion("Biometric ID not available")
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] (success, evaluateError) in
            
            if success {
                DispatchQueue.main.async {
                    self?.next(newPage: Dashboard.homePage)
                    withAnimation(.easeIn(duration: 0.2)) {
                        AuthenticationView.hideMetric = 0
                        AuthenticationView.lastHide = true
                    }
                    completion(nil)
                }
            } else {
                let message: String
                switch evaluateError {
                case LAError.authenticationFailed?:
                  message = "There was a problem verifying your identity."
                case LAError.userCancel?:
                  message = "You pressed cancel."
                case LAError.userFallback?:
                  message = "You pressed password."
                case LAError.biometryNotAvailable?:
                  message = "Face ID/Touch ID is not available."
                case LAError.biometryNotEnrolled?:
                  message = "Face ID/Touch ID is not set up."
                case LAError.biometryLockout?:
                  message = "Face ID/Touch ID is locked."
                default:
                  message = "Face ID/Touch ID may not be configured"
                }
                DispatchQueue.main.async {
                    self?.firestore.authRedirect = Page.loginPage
                    withAnimation(.easeInOut(duration: 0.2)) {
                        AuthenticationView.hideMetric = 0
                        AuthenticationView.lastHide = true
                    }
                    completion(evaluateError?.localizedDescription ?? message)
                }
            }
        }
    }
    
    func bioIDLoginAction() {
        self.authenticateUser() { [weak self] message in
            if let message = message {
                print(message)
                //self?.firestore.authRedirect = self?.firestore.currentPage == .loginPage ? .loginPage : .welcomePage
                self?.firestore.authRedirect = Page.loginPage
            } else {
                self?.firestore.authRedirect = Page.welcomePage
                self?.next(newPage: Dashboard.homePage)
            }
        }
    }
    
    func next(newPage: Dashboard) {
        if ((newPage == Dashboard.startPage) && (self.firestore.authRedirect == Page.loginPage)) {
            self.firestore.isLoggedIn = false
            self.firestore.profile = Profile.default
            self.firestore.appointment = Appointment.default
        }
        self.firestore.showSidebar = false
        self.firestore.showProfile = false
        withAnimation(.easeInOut(duration: 0.25)) {
            self.firestore.currentPage = newPage
        }
    }
    
    func login(uid: String, email: String) {
        self.firestore.isLoggedIn = true
        self.fetchProfile(uid: uid, email: email)
        self.fetchTrainings()
        self.fetchUsers()
        self.next(newPage: Dashboard.homePage)
    }
    
    func fetchProfile(uid: String, email: String) {
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        
        let df = self.dateFormatter!
    
        db.collection("profiles").document(email).getDocument { (document, error) in
            guard let document = document, document.exists else {
                print("No such document available")
                self.setProfile(parameters: ["uid": uid, "email": email, "admin": false, "member": true, "level": Profile.Level.nine.rawValue, "balance": 0, "info": "new", "timeslot": Date(), "focus": Profile.Focus.tb.rawValue, "username": email.components(separatedBy: "@")[0]])
                self.fetchProfile(uid: uid, email: email)
                return
            }
            
            if let data = document.data() {
                var dateStrAppt: String
                var apptTime: Date
                
                let dataId = data["uid"]as? String ?? uid
                let dataEmail = data["email"]as? String ?? email
                let dataAdmin = data["isAdmin"]as? Bool ?? false
                let dataMember = data["isMember"]as? Bool ?? false
                let dataUser = data["username"]as? String ?? email.components(separatedBy: "@")[0]
                let dataLevel = data["currentLevel"]as? String ?? Profile.Level.nine.rawValue
                let dataBalance = data["outstandingBalance"]as? Int ?? 0
                let dataInfo = data["userInfo"]as? String ?? "new"
                let dataFocus = data["focusTarget"]as? String ?? Profile.Focus.tb.rawValue
                
                if let dataAppt = data["nextAppointment"]as? Timestamp {
                    let dateVal = dataAppt.dateValue()
                    dateStrAppt = df.string(from: dateVal)
                } else {
                    dateStrAppt = df.string(from: Date())
                }
                
                apptTime = df.date(from: dateStrAppt)!
                
                self.firestore.profile.uid = dataId
                self.firestore.profile.email = dataEmail
                self.firestore.profile.isAdmin = dataAdmin
                self.firestore.profile._username = dataUser
                self.firestore.profile.isMember = dataMember
                self.firestore.profile.currentLevel = dataLevel
                self.firestore.profile.outstandingBalance = dataBalance
                self.firestore.profile.userInfo = dataInfo
                self.firestore.profile.focusTarget = dataFocus
                self.firestore.profile.nextAppointment = apptTime
            } else {
                self.setProfile(parameters: ["uid": uid, "email": email, "admin": false, "member": true, "level": Profile.Level.nine.rawValue, "balance": 0, "info": "new", "timeslot": Date(), "focus": Profile.Focus.tb.rawValue, "username": email.components(separatedBy: "@")[0]])
                self.fetchProfile(uid: uid, email: email)
                return
            }
        }
        
        let docRef = db.collection("appointments")
            .whereField("uid", isEqualTo: uid)
            .order(by: "nextAppointment", descending: true)
            .limit(to: 1)

        docRef.getDocuments { (snapshot, error) in
            guard let snapshot = snapshot, error == nil else {
                print("error", error ?? "")
                return
            }
            
            print("Number of documents: \(snapshot.documents.count)")
            
            let docAppts: [Appointment] = snapshot.documents.compactMap { docSnap in
                var dateStrAppt: String
                var apptTime: Date
                
                let docData = docSnap.data()
                let uid = docData["uid"] as? String ?? ""
                let numAppt = docData["numAppt"] as? Int ?? 0
                let invo = docData["invoice"]as? String ?? Appointment.StripeLink.zero.rawValue
                let confirm = docData["isConfirmed"]as? Bool ?? false
                let complete = docData["isCompleted"]as? Bool ?? false
                let paid = docData["isPaid"]as? Bool ?? false
                let cancel = docData["isCanceled"]as? Bool ?? false
                let reason = docData["cancelReason"] as? String ?? ""
                
                if let dataAppt = docData["nextAppointment"]as? Timestamp {
                    let dateVal = dataAppt.dateValue()
                    dateStrAppt = df.string(from: dateVal)
                } else {
                    dateStrAppt = df.string(from: Date())
                }
                
                apptTime = df.date(from: dateStrAppt)!
                
                let docAppt = Appointment(uid: uid, email: email, invoice: invo, isConfirmed: confirm, isCompleted: complete, isPaid: paid, isCanceled: cancel, cancelReason: reason, numAppt: numAppt, nextAppointment: apptTime)
                
                self.addAppt(withEmail: email, uid: uid, invoice: invo, confirm: confirm, complete: complete, paid: paid, cancel: cancel, reason: reason, numAppt: numAppt, timeslot: apptTime)
                
                return docAppt
            }
            self.firestore.appointment = docAppts[0]
            self.firestore.focusAppt = docAppts[0]
        }
    }
    
    func setProfile(parameters: [String: Any?]) {
        
        let db = Firestore.firestore()
        let email = parameters["email"]as? String ?? ""
        let uid = parameters["uid"]as? String ?? ""
        
        var pf = self.profile!
        
        if pf._username == "new_profile" {
            if email == self.firestore.profile.email {
                pf = self.profile!
            } else {
                self.fetchUser(withEmail: email)
                pf = self.firestore.user
            }
        }
        
        let params: [String: Any?] = [
            "admin": parameters["admin"]as? Bool ?? pf.isAdmin,
            "member": parameters["member"]as? Bool ?? pf.isMember,
            "level": parameters["level"]as? String ?? pf.currentLevel,
            "balance": parameters["balance"]as? Int ?? pf.outstandingBalance,
            "timeslot": parameters["timeslot"]as? Date ?? pf.nextAppointment,
            "info": parameters["info"]as? String ?? pf.userInfo,
            "focus": parameters["focus"]as? String ?? pf.focusTarget,
            "username": parameters["username"]as? String ?? pf._username!
        ]
        
        // Add a new document or update a document in collection "profiles"
        db.collection("profiles").document(email).setData([
            "uid": uid,
            "email": email,
            "isAdmin": params["admin"]!!,
            "isMember": params["member"]!!,
            "currentLevel": params["level"]!!,
            "outstandingBalance": params["balance"]!!,
            "nextAppointment": params["timeslot"]!!,
            "userInfo": params["info"]!!,
            "focusTarget": params["focus"]!!,
            "username": params["username"]!!
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    func deleteProfile(_ email: String) {
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        
        let docRef = db.collection("profiles").document(email)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                docRef.delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                        return
                    } else {
                        print("Document successfully removed!")
                        return
                    }
                }
            } else {
                print("Document does not exist")
                return
            }
        }
    }
    
    func fetchTrainings() {
        self.firestore.appts = [:]
        self.firestore.appointments = []
        self.firestore.nextId = 0
        self.firestore.activeApptIds = []
        self.firestore.confirmedApptIds = []
        self.firestore.completedApptIds = []
        self.firestore.canceledApptIds = []
        
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        
        let docRef = db.collection("appointments")

        docRef.getDocuments { (snapshot, error) in
            guard
                let snapshot = snapshot, error == nil
            else {
                print("error", error ?? "")
                return
            }
            
            print("Number of documents: \(snapshot.documents.count)")
            
            self.firestore.appointments = snapshot.documents.compactMap { docSnap in
                var dateStrAppt: String
                var apptTime: Date
                
                let df = self.dateFormatter!
                
                let docData = docSnap.data()
                let cancel = docData["isCanceled"]as? Bool ?? false
                
                if !cancel {
                    let uid = docData["uid"]as? String ?? ""
                    let userEmail = docData["email"] as? String ?? ""
                    let numAppt = docData["numAppt"] as? Int ?? 0
                    let invoice = docData["invoice"]as? String ?? Appointment.StripeLink.zero.rawValue
                    let confirm = docData["isConfirmed"]as? Bool ?? false
                    let complete = docData["isCompleted"]as? Bool ?? false
                    let paid = docData["isPaid"]as? Bool ?? false
                    let reason = docData["cancelReason"]as? String ?? ""
                    
                    if let dataAppt = docData["nextAppointment"]as? Timestamp {
                        let dateVal = dataAppt.dateValue()
                        dateStrAppt = df.string(from: dateVal)
                    } else {
                        dateStrAppt = df.string(from: Date())
                    }
                    
                    apptTime = df.date(from: dateStrAppt)!
                    
                    let appointment = Appointment(uid: uid, email: userEmail, invoice: invoice, isConfirmed: confirm, isCompleted: complete, isPaid: paid, isCanceled: cancel, cancelReason: reason, numAppt: numAppt, nextAppointment: apptTime)
                    
                    self.addAppt(withEmail: userEmail, uid: uid, invoice: invoice, confirm: confirm, complete: complete, paid: paid, cancel: cancel, reason: reason, numAppt: numAppt, timeslot: apptTime)
                 
                    return appointment
                } else {
                    return nil
                }
            }
        }
    }
    
    func fetchTraining(for email: String) {
        getUserApptData(doc: email) { docData in
            var dateStrAppt: String
            var apptTime: Date
            
            let df = self.dateFormatter!
            
            if let docData = docData,
               let uid = docData["uid"] as? String {
                let numAppt = docData["numAppt"] as? Int ?? 0
                let invo = docData["invoice"]as? String ?? Appointment.StripeLink.zero.rawValue
                let confirm = docData["isConfirmed"]as? Bool ?? false
                let complete = docData["isCompleted"]as? Bool ?? false
                let paid = docData["isPaid"]as? Bool ?? false
                let cancel = docData["isCanceled"]as? Bool ?? false
                let reason = docData["cancelReason"] as? String ?? ""
                
                if let dataAppt = docData["nextAppointment"]as? Timestamp {
                    let dateVal = dataAppt.dateValue()
                    dateStrAppt = df.string(from: dateVal)
                } else {
                    dateStrAppt = df.string(from: Date())
                }
                
                apptTime = df.date(from: dateStrAppt)!
                
                let docAppt = Appointment(uid: uid, email: email, invoice: invo, isConfirmed: confirm, isCompleted: complete, isPaid: paid, isCanceled: cancel, cancelReason: reason, numAppt: numAppt, nextAppointment: apptTime)
            
                if email == self.firestore.profile.email {
                    self.firestore.appointment = docAppt
                }
                self.firestore.focusAppt = docAppt
            } else {
                self.firestore.focusAppt = Appointment.default
            }
        }
    }
    
    func setTraining(parameters: [String: Any?]) {
        var pf = self.profile!
        var apptNum = parameters["numAppt"]as? Int ?? 0
        
        let db = Firestore.firestore()
        let email = parameters["email"]as? String ?? ""
        
        if email != pf.email {
            self.fetchUser(withEmail: email)
            self.fetchTraining(for: email)
            pf = self.firestore.user
        } else {
            self.firestore.user = pf
        }
        
        let focus = self.focusAppt!
        
        let params: [String: Any?] = [
            "uid": parameters["uid"]as? String ?? self.firestore.user.uid, //pf.uid
            "invoice": parameters["invoice"]as? String ?? Appointment.StripeLink.hundred.rawValue,
            "confirm": parameters["confirm"]as? Bool ?? false,
            "complete": parameters["complete"]as? Bool ?? false,
            "paid": parameters["paid"]as? Bool ?? false,
            "cancel": parameters["cancel"]as? Bool ?? false,
            "reason": parameters["reason"]as? String ?? "",
            "timeslot": parameters["timeslot"]as? Date ?? Date(),
            "mode": parameters["mode"]as? String ?? "new"
        ]
        
        var apptName: String = "\(email.components(separatedBy: "@")[0])_appointment"
        
        var newBalance: Int = self.firestore.user.outstandingBalance
        let invoice = params["invoice"]! as! String
        let intInvoice: Int = Int(invoice.replacingOccurrences(of: "$", with: "")) ?? 0
        
        if ((focus.uid == "abc123") || (params["mode"]! as! String == "new") || (!(!(params["paid"]! as! Bool) && !(params["complete"]! as! Bool) && focus.isPaid && focus.isCompleted) && (params["mode"]! as! String == "edit"))) {
            
        } else if ((((params["mode"]! as! String) == "add") || (!(params["cancel"]! as! Bool) || !focus.isCanceled)) || (!(params["paid"]! as! Bool) && !(params["complete"]! as! Bool) && focus.isPaid && focus.isCompleted)) {
            apptNum += 1
        }
                
        if (((params["cancel"]! as! Bool) && !focus.isCanceled && focus.isConfirmed && !focus.isPaid) || (!(params["confirm"]! as! Bool) && focus.isConfirmed) || ((params["paid"]! as! Bool) && !focus.isPaid && ((params["mode"]! as! String) == "edit"))) {
            newBalance -= intInvoice
        } else if (((params["confirm"]! as! Bool) && !focus.isConfirmed) || ((params["mode"]! as! String) == "add") || (!(params["paid"]! as! Bool) && focus.isPaid && ((params["mode"]! as! String) == "edit"))) {
            newBalance += intInvoice
            if (((params["mode"]! as! String) == "add") && focus.isConfirmed && !focus.isCanceled && !focus.isPaid) {
                let oldInvoice: Int = Int(focus.invoice.replacingOccurrences(of: "$", with: "")) ?? 0
                newBalance -= oldInvoice
            }
        }
        
        if apptNum > 0 {
            apptName = "\(apptName)_\(apptNum)"
        }
        
        let docRefAppt = db.collection("appointments").document(apptName)
    
        docRefAppt.setData([
            "uid": params["uid"]!!,
            "email": email,
            "invoice": params["invoice"]!!,
            "isConfirmed": params["confirm"]!!,
            "isCompleted": params["complete"]!!,
            "isPaid": params["paid"]!!,
            "isCanceled": params["cancel"]!!,
            "cancelReason": params["reason"]!!,
            "numAppt": apptNum,
            "nextAppointment": params["timeslot"]!!
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        let docRefTwo = db.collection("profiles").document(email)
        
        docRefTwo.setData(["nextAppointment": params["timeslot"]!!,
                           "outstandingBalance": newBalance], merge: true) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        pf = self.profile!
        
        if pf.email == email {
            self.fetchProfile(uid: pf.uid, email: email)
        }
        
        if pf.isAdmin {
            self.fetchTrainings()
        }
    }
    
    func deleteUserTrainings(for email: String) {
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        
        var numAppt: UInt8 = 0
        var apptName = "\(email.components(separatedBy: "@")[0])_appointment"
        var isDeleting = true
        
        while isDeleting {
            let docRef = db.collection("appointments").document(apptName)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    docRef.delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                            isDeleting = false
                        } else {
                            print("Document successfully removed!")
                            let newNum: UInt8 = numAppt + 1
                            if numAppt == 0 {
                                apptName = "\(apptName)_1"
                            } else {
                                let newName = apptName.removeLast()
                                apptName = "\(newName)\(newNum)"
                            }
                            numAppt = newNum
                        }
                    }
                } else {
                    print("Document does not exist")
                    isDeleting = false
                }
            }
        }
        self.fetchTrainings()
    }
    
    func deleteAllTrainings() {
        let db = Firestore.firestore()
        let settings = db.settings
        db.settings = settings
        
        let appts = db.collection("appointments")
    
        appts.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let docId = document.documentID
                    print("\(docId) => \(data)")
                    
                    appts.document(docId).delete() { err in
                        if let err = err {
                            print("Error removing document: \(err)")
                            return
                        } else {
                            print("Document successfully removed!")
                            return
                        }
                    }
                }
            }
        }
    }
    
    func fetchUsers() {
        self.firestore.users = [:]
        self.firestore.allUsers = []
        self.firestore.nextUserId = 0
        self.firestore.activeUserIds = []
        self.firestore.potentialUserIds = []
        
        getDocuments(of: "profiles") { docs in
            if let docs = docs {
                self.firestore.allUsers = docs.compactMap { docSnap in
                    let data = docSnap.data()
                    
                    let id = self.firestore.nextUserId
                    let userEmail = data["email"]as? String ?? ""
                    let member = data["isMember"]as? Bool ?? false
                    let balance = data["outstandingBalance"]as? Int ?? 0

                    let user = User(id: id, email: userEmail, isMember: member, outstandingBalance: balance)
                    self.addUser(withEmail: userEmail, member: member, balance: balance)
                    
                    return user
                }
            }
        }
    }
    
    func fetchUser(withEmail email: String) {
        getProfileData(email: email) { data in
            var dateStrAppt: String
            var apptTime: Date
            
            let df = self.dateFormatter!
            
            if let data = data,
               let dataId = data["uid"]as? String {
                let dataEmail = data["email"]as? String ?? email
                let dataAdmin = data["isAdmin"]as? Bool ?? false
                let dataMember = data["isMember"]as? Bool ?? false
                let dataUser = data["username"]as? String ?? email.components(separatedBy: "@")[0]
                let dataLevel = data["currentLevel"]as? String ?? Profile.Level.nine.rawValue
                let dataBalance = data["outstandingBalance"]as? Int ?? 0
                let dataInfo = data["userInfo"]as? String ?? "new"
                let dataFocus = data["focusTarget"]as? String ?? Profile.Focus.tb.rawValue
                
                if let dataAppt = data["nextAppointment"]as? Timestamp {
                    let dateVal = dataAppt.dateValue()
                    dateStrAppt = df.string(from: dateVal)
                } else {
                    dateStrAppt = df.string(from: Date())
                }
                
                apptTime = df.date(from: dateStrAppt)!
                
                self.firestore.user.uid = dataId
                self.firestore.user.email = dataEmail
                self.firestore.user.isAdmin = dataAdmin
                self.firestore.user._username = dataUser
                self.firestore.user.isMember = dataMember
                self.firestore.user.currentLevel = dataLevel
                self.firestore.user.outstandingBalance = dataBalance
                self.firestore.user.userInfo = dataInfo
                self.firestore.user.focusTarget = dataFocus
                self.firestore.user.nextAppointment = apptTime
            }
        }
    }
    
    /// Inserts a new `User` into the list with the given details.
    func addUser(withEmail email: String, member: Bool, balance: Int) {
        let id = self.firestore.nextUserId
        self.firestore.nextUserId += 1

        self.firestore.users[id] = User(id: id, email: email, isMember: member, outstandingBalance: balance)
            
        if member {
            self.firestore.activeUserIds.append(id)
        } else {
            self.firestore.potentialUserIds.append(id)
        }
    }
    
    func deleteUser() {
        guard
            let user = Auth.auth().currentUser
        else { return }

        user.delete { error in
            if let error = error {
                print("Error removing document: \(error.localizedDescription)")
            } else {
                print("Successfully deleted user from FirebaseAuth")
            }
        }
    }
    /*
    private var cancellable: AnyCancellable?
    
    private func allowDataflow(loader: FirestoreLoader) {
        loader.profilePublisher { [weak self] publisher in
            self?.cancellable = publisher.sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error retrieving profile: \(error)")
                }
            } receiveValue: { profile in
                self?.firestore.profile = profile
            }
        }
    }
    
    private var cancellableAppt: AnyCancellable?
    
    private func allowDataflowAppt(loader: FirestoreLoader) {
        loader.appointmentPublisher { [weak self] publisher in
            self?.cancellableAppt = publisher.sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error retrieving appointment: \(error)")
                }
            } receiveValue: { appointment in
                self?.firestore.appointment = appointment
            }
        }
    }
    */
                  
    /// Inserts a new `Appointment` into the list with the given details.
    func addAppt(withEmail email: String, uid: String, invoice: String, confirm: Bool, complete: Bool, paid: Bool, cancel: Bool, reason: String, numAppt: Int, timeslot: Date) {
        let id = self.firestore.nextId
        self.firestore.nextId += 1

        self.firestore.appts[id] = TodoItem(id: id, uid: uid, email: email, invoice: invoice, isConfirmed: confirm, isCompleted: complete, isPaid: paid, isCanceled: cancel, cancelReason: reason, numAppt: numAppt, nextAppointment: timeslot)
            
        if cancel {
            self.firestore.canceledApptIds.append(id)
        } else if complete {
            self.firestore.completedApptIds.append(id)
        } else if confirm {
            self.firestore.confirmedApptIds.append(id)
        } else {
            self.firestore.activeApptIds.append(id)
        }
    }

    func updateAppt(withId id: Int, isConfirmed: Bool, isCompleted: Bool, isPaid: Bool, isCanceled: Bool) {
        guard
            let appt = self.firestore.appts[id],
            appt.isConfirmed != isConfirmed || appt.isCompleted != isCompleted || appt.isCanceled != isCanceled //|| appt.isPaid != isPaid
        else { return }

        if isCanceled {
            self.firestore.activeApptIds.removeAll { $0 == id }
            self.firestore.confirmedApptIds.removeAll { $0 == id }
            self.firestore.completedApptIds.removeAll { $0 == id }
            self.firestore.canceledApptIds.append(id)
        } else if isCompleted {
            self.firestore.canceledApptIds.removeAll{ $0 == id }
            self.firestore.activeApptIds.removeAll { $0 == id }
            self.firestore.confirmedApptIds.removeAll { $0 == id }
            self.firestore.completedApptIds.append(id)
        } else if isConfirmed {
            self.firestore.canceledApptIds.removeAll{ $0 == id }
            self.firestore.activeApptIds.removeAll { $0 == id }
            self.firestore.completedApptIds.removeAll { $0 == id }
            self.firestore.confirmedApptIds.append(id)
        } else if !isConfirmed {
            self.firestore.canceledApptIds.removeAll{ $0 == id }
            self.firestore.confirmedApptIds.removeAll { $0 == id }
            self.firestore.completedApptIds.removeAll { $0 == id }
            self.firestore.activeApptIds.append(id)
        }
        
        // self.firestore.apptChanges.append(appt)
    }
    
    func deleteActiveAppts(atOffsets offsets: IndexSet) {
        for index in offsets {
            let appt = self.firestore.appts[self.firestore.activeApptIds[index]]!
            self.firestore.appts.removeValue(forKey: self.firestore.activeApptIds[index])
            
            DispatchQueue.main.async {
                self.setTraining(parameters: ["email": appt.email, "invoice": appt.invoice, "confirm": appt.isConfirmed, "complete": appt.isCompleted, "paid": appt.isPaid, "cancel": true, "reason": "Removed by administration", "timeslot": Date(), "mode": "edit"])
            }
        }

        self.firestore.activeApptIds.remove(atOffsets: offsets)
    }

    func moveActiveAppts(fromOffsets source: IndexSet, toOffset destination: Int) {
        self.firestore.activeApptIds.move(fromOffsets: source, toOffset: destination)
    }
    
    func deleteConfirmedAppts(atOffsets offsets: IndexSet) {
        for index in offsets {
            let appt = self.firestore.appts[self.firestore.confirmedApptIds[index]]!
            self.firestore.appts.removeValue(forKey: self.firestore.confirmedApptIds[index])
                    
            DispatchQueue.main.async {
                self.setTraining(parameters: ["email": appt.email, "invoice": appt.invoice, "confirm": appt.isConfirmed, "complete": appt.isCompleted, "paid": appt.isPaid, "cancel": true, "reason": "Removed by administration", "timeslot": Date(), "mode": "edit"])
            }
        }

        self.firestore.confirmedApptIds.remove(atOffsets: offsets)
    }

    func moveConfirmedAppts(fromOffsets source: IndexSet, toOffset destination: Int) {
        self.firestore.confirmedApptIds.move(fromOffsets: source, toOffset: destination)
    }
    
    func deleteCompletedAppts(atOffsets offsets: IndexSet) {
        for index in offsets {
            let appt = self.firestore.appts[self.firestore.completedApptIds[index]]!
            self.firestore.appts.removeValue(forKey: self.firestore.completedApptIds[index])
                    
            DispatchQueue.main.async {
                self.setTraining(parameters: ["email": appt.email, "invoice": appt.invoice, "confirm": appt.isConfirmed, "complete": appt.isCompleted, "paid": appt.isPaid, "cancel": true, "reason": "Finalized by administration", "timeslot": appt.nextAppointment, "mode": "edit"])
            }
        }
        
        self.firestore.completedApptIds.remove(atOffsets: offsets)
    }

    func moveCompletedAppts(fromOffsets source: IndexSet, toOffset destination: Int) {
        self.firestore.completedApptIds.move(fromOffsets: source, toOffset: destination)
    }
}
