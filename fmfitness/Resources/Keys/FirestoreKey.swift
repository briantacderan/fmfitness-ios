//
//  FirestoreKey.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/18/22.
/*

import SwiftUI

private struct FirestoreKey: EnvironmentKey {
    static let defaultValue = FirestoreManager.shared
}

extension EnvironmentValues {
    var firestore: FirestoreManager {
        get { self[FirestoreKey.self] }
        set { self[FirestoreKey.self] = newValue }
    }
}
*/
import SwiftUI

private struct EditKey: EnvironmentKey {
    static let defaultValue = EditMode.inactive
}

extension EnvironmentValues {
    var editMode: EditMode {
        get { self[EditKey.self] }
        set { self[EditKey.self] = newValue }
    }
}
