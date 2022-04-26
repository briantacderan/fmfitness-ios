//
//  File.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/18/22.
//

import Foundation
import SwiftUI

private struct AppointmentKey: EnvironmentKey {
    static let defaultValue = FirestoreManager.shared
}

extension EnvironmentValues {
  var appointment: FirestoreManager {
    get { self[AppointmentKey.self] }
    set { self[AppointmentKey.self] = newValue }
  }
}
