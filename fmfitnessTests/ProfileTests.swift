//
//  ProfileTests.swift
//  ProfileTests
//
//  Created by Brian Tacderan on 2/18/22.
//

import XCTest
@testable import fmfitness

class ProfileTests: XCTestCase {

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testProfileEmail() throws {
        let profile = Profile.default
        XCTAssertEqual(profile.email, "new_profile@email.com")
        XCTAssertEqual(profile._username, "new_profile")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
