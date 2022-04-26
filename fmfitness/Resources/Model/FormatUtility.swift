//
//  FormatUtility.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/18/22.
//

import Foundation

extension Formatter {
    static let apptFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        return formatter
    }()
}
