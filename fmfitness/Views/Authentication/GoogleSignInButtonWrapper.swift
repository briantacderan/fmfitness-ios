//
//  GoogleSignInButtonWrapper.swift
//  fmfitness
//
//  Created by Brian Tacderan on 1/26/22.
//

import SwiftUI
import GoogleSignIn

/// A wrapper for `GIDSignInButton` so that it can be used in SwiftUI.
struct GoogleSignInButtonWrapper: UIViewRepresentable {
    let handler: () -> Void

    init(handler: @escaping () -> Void) {
        self.handler = handler
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIView(context: Context) -> GIDSignInButton {
        let signInButton = GIDSignInButton()
        signInButton.addTarget(context.coordinator,
                               action: #selector(Coordinator.callHandler),
                               for: .touchUpInside)
        signInButton.style = .iconOnly
        signInButton.colorScheme = .light
        return signInButton
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.handler = handler
    }
}

extension GoogleSignInButtonWrapper {
  class Coordinator {
    var handler: (() -> Void)?

    @objc func callHandler() {
      handler?()
    }
  }
}
