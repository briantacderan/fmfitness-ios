//
//  AuthenticationKey.swift
//  fm-fitness
//
//  Created by Brian Tacderan on 6/17/22.
//

import SwiftUI

private struct AuthenticationKey: EnvironmentKey {
    static let defaultValue = AuthenticationViewModel.shared
}

extension EnvironmentValues {
    var authViewModel: AuthenticationViewModel {
        get { self[AuthenticationKey.self] }
        set { self[AuthenticationKey.self] = newValue }
    }
}
