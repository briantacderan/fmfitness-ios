//
//  CircleImage.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/18/22.
//

import SwiftUI

struct CircleImage: View {
    var image: ProfileImageView

    var body: some View {
        image
            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            .overlay {
                Circle().stroke(.white, lineWidth: 4)
            }
            .shadow(radius: 7)
    }
}
