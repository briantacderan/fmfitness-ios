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
    
    var frameSize: CGFloat

    init(profile: GIDProfileData, frameSize: CGFloat) {
        self.imageLoader = ProfileImageLoader(profile: profile)
        self.frameSize = frameSize
    }

    var body: some View {
        Image(uiImage: imageLoader.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: frameSize, height: frameSize, alignment: .center)
            .scaledToFit()
            .clipShape(Circle())
            .accessibilityLabel(Text("Profile image."))
    }
}
