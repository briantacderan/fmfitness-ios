//
//  TrainingTests.swift
//  fm-fitnessTests
//
//  Created by Brian Tacderan on 6/12/22.
//
/*

import XCTest
import SwiftUI
import Firebase

@testable import fm_fitness

class TrainingTests: XCTestCase {
    //@StateObject var firestore = FirestoreManager.shared
    //@StateObject var schedule = Scheduler.shared

    @State var signUpProcessing = false
    @State var signUpErrorMessage = ""
    @State var registrationDidSucceed = false
    
    @State var signInProcessing: Bool = false
    @State var signInErrorMessage: String = ""
    @State var authenticationDidSucceed: Bool = false
    
    let userEmail = "training@test.io"
    let userPass = "test123"
    
    override func setUp() async throws {
        // This is the setUp() async instance method.
        // XCTest calls it before each test method.
        // Perform any asynchronous setup in this method.
    }
    
    override func setUpWithError() throws {
        // This is the setUpWithError() instance method.
        // XCTest calls it before each test method.
        // Set up any synchronous per-test state that might throw errors here.
        
        signUpUser(userEmail: userEmail, userPassword: userPass)
        signInUser(userEmail: userEmail, userPassword: userPass)
    }
    
    override func setUp() {
        // This is the setUp() instance method.
        // XCTest calls it before each test method.
        // Set up any synchronous per-test state here.
        super.setUp()
        
        scheduler.weekIndex = 1
        scheduler.dayIndex = 4
        scheduler.timeIndex = 3
        
        firestore.setTraining(parameters: [
            "timeslot": scheduler.trainingTime,
            "email": userEmail
        ])
     }
    
    override func tearDown() {
        // This is the tearDown() instance method.
        // XCTest calls it after each test method.
        // Perform any synchronous per-test cleanup here.
        super.tearDown()
     }

    override func tearDownWithError() throws {
        // This is the tearDownWithError() instance method.
        // XCTest calls it after each test method.
        // Perform any synchronous per-test cleanup that might throw errors here.
        
        firestore.deleteUser()
    }
    
    override func tearDown() async throws {
        // This is the tearDown() async instance method.
        // XCTest calls it after each test method.
        // Perform any asynchronous per-test cleanup here.
    }
    
    func testTrainingSetUp() throws {
        XCTAssertEqual(firestore.profile.email, userEmail)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func signUpUser(userEmail: String, userPassword: String) {
        signUpProcessing = true
        
        Auth.auth().createUser(withEmail: userEmail,
                               password: userPassword) { [weak self] res, error in
            guard error == nil else {
                self?.signUpErrorMessage = error!.localizedDescription
                self?.signUpProcessing = false
                return
            }
            
            switch res {
            case .none:
                print("Could not create account")
                self?.signUpProcessing = false
            case .some(_):
                self?.firestore.setProfile(parameters: ["email": userEmail, "admin": false, "member": true, "level": Profile.Level.nine.rawValue, "balance": 0, "timeslot": Date(), "info": "new", "focus": Profile.Focus.tb.rawValue, "username": userEmail.components(separatedBy: "@")[0]])
                print("User created")
                
                self?.signUpErrorMessage = ""
                self?.registrationDidSucceed = true
                self?.signUpProcessing = false
            }
        }
    }
    
    func signInUser(userEmail: String, userPassword: String) {
        signInProcessing = true
        
        Auth.auth().signIn(withEmail: userEmail,
                           password: userPassword) { [weak self] authResult, error in
            guard error == nil else {
                self?.signInProcessing = false
                self?.signInErrorMessage = error!.localizedDescription
                return
            }
            
            switch authResult {
            case .none:
                print("Could not sign in user.")
                self?.signInProcessing = false
            case .some(_):
                print("User signed in")
                self?.signInProcessing = false
                self?.signInErrorMessage = ""
                self?.authenticationDidSucceed = true
                self?.firestore.firstLogin = true
                self?.firestore.login(email: userEmail)
            }
        }
    }
}

*/
