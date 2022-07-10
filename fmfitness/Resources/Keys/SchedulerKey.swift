//
//  SchedulerKey.swift
//  fm-fitness
//
//  Created by Brian Tacderan on 6/14/22.
//

import SwiftUI

private struct SchedulerKey: EnvironmentKey {
    static let defaultValue = SchedulerModel.shared
}

extension EnvironmentValues {
    var scheduler: SchedulerModel {
        get { self[SchedulerKey.self] }
        set { self[SchedulerKey.self] = newValue }
    }
}
