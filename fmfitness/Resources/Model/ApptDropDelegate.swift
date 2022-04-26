//
//  ApptDropDelegate.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/18/22.
//

import SwiftUI

struct ApptDropDelegate: DropDelegate {
    @Binding var focusId: Int?

    func performDrop(info: DropInfo) -> Bool {
        guard
            info.hasItemsConforming(to: [AdminData.typeIdentifier])
        else { return false }

        let apptProviders = info.itemProviders(for: [AdminData.typeIdentifier])
        guard
            let apptProvider = apptProviders.first
        else { return false }

        apptProvider.loadObject(ofClass: AdminData.self) { appointment, _ in
            let appointment = appointment as? AdminData

            DispatchQueue.main.async {
                self.focusId = appointment?.id
            }
        }
        return true
    }
}
