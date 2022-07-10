//
//  ControllerKey.swift
//  fm-fitness
//
//  Created by Brian Tacderan on 6/17/22.

import SwiftUI

private struct ControllerKey: EnvironmentKey {
    static let defaultValue = PageController.shared
}

extension EnvironmentValues {
    var controller: PageController {
        get { self[ControllerKey.self] }
        set { self[ControllerKey.self] = newValue }
    }
}
