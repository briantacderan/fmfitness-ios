//
//  LoginTests.swift
//  fmfitnessTests
//
//  Created by Brian Tacderan on 2/21/22.
//

import XCTest
import SwiftUI
// import GoogleSignIn
@testable import fmfitness

class LoginTests: XCTestCase {
    
    var firestore = FirestoreManager()
    var authViewModel = AuthenticationViewModel()
    
    var signInProcessing = false
    var signInErrorMessage = ""
    var authenticationDidSucceed = true
    
    let testEmail = "shoehead_brian@yahoo.com"
    let testPass = "asdfasdf"
    
    enum Page {
        case loginPage
        case registerPage
        case homePage
    }
    
    override func setUpWithError() throws {
        // firestore.login(email: testEmail)
    }

    override func tearDownWithError() throws {
        // firestore.next(newPage: .loginPage)
    }

    /*
    func testFirestoreFetch() throws {
        firestore.fetchProfile(email: testEmail)
        XCTAssertEqual(firestore.profile.email, testEmail)
    }
     */

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
