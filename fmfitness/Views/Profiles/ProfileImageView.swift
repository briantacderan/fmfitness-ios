//
//  ProfileImageView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/26/22.
//

import GoogleSignIn
import SwiftUI

struct ProfileImageView: View {
    
    @ObservedObject var imageLoader: ProfileImageLoader

    init(profile: GIDProfileData) {
        self.imageLoader = ProfileImageLoader(profile: profile)
    }

    var body: some View {
        Image(uiImage: imageLoader.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 155, height: 155, alignment: .center)
            .scaledToFit()
            .clipShape(Circle())
            .accessibilityLabel(Text("Profile image."))
    }
}
