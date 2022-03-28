//
//  SwiftUIView.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/26/22.
//

import Combine
import SwiftUI
import GoogleSignIn

/// An observable class for loading the current user's profile image.
final class ProfileImageLoader: ObservableObject {
    
    private let profile: GIDProfileData
    private let imageLoaderQueue = DispatchQueue(label: "com.thetacderancode.fmfitness")
  
    /// A `UIImage` property containing the current user's profile image.
    /// - note: This will default to a placeholder, and updates will be published to subscribers.
    @Published var image = UIImage(named: "PlaceholderAvatar")!

    /// Creates an instance of this loader with provided user profile.
    /// - note: The instance will asynchronously fetch the image data upon creation.
    init(profile: GIDProfileData) {
        self.profile = profile
        guard profile.hasImage else {
            return
        }

        imageLoaderQueue.async {
            let dimension = 45 * UIScreen.main.scale
            guard let url = profile.imageURL(withDimension: UInt(dimension)),
                  let data = try? Data(contentsOf: url),
                  let image = UIImage(data: data)
            else { return }
            
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}
