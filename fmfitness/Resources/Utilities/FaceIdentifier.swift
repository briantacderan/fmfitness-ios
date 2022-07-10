//
//  FaceIdentifier.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/23/22.
//
/*

import LocalAuthentication
import Combine
import SwiftUI

enum BiometricType {
    case touchID
    case faceID
    case none
}

final class BiometricIDAuth: ObservableObject {
    
    static var shared = BiometricIDAuth()
    @ObservedObject var firestore = FirestoreManager.shared
    
    let didChange = PassthroughSubject<BiometricIDAuth, Never>()
    let willChange = PassthroughSubject<BiometricIDAuth, Never>()
    
    let context = LAContext()
    var reason = "Logging in with Biometric ID Authentication"
    
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
                    withAnimation {
                        self?.authRedirect = .loginPage
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
                //self?.authRedirect = self?.firestore.currentPage == .loginPage ? .loginPage : .welcomePage
                self?.authRedirect = .loginPage
            } else {
                self?.authRedirect = .welcomePage
                self?.controller.next(newPage: .homePage)
            }
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
*/
