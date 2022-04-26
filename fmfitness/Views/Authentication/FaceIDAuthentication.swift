//
//  FaceIDAuthentication.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/23/22.
//

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
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { (success, evaluateError) in
            
            let message: String
            switch evaluateError {
            // 3
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
          
            if success {
                DispatchQueue.main.async {
                    completion(message)
                }
            } else {
                DispatchQueue.main.async {
                    completion(evaluateError?.localizedDescription ?? message)
                        
                }
            }
        }
    }
}

