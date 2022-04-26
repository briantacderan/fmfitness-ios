//
//  ListUtility.swift
//  fmfitness
//
//  Created by Brian Tacderan on 4/18/22.
//

import SwiftUI

// MARK: - Environment

private struct ApplyListAppearanceKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var applyListAppearance: Bool {
        get { self[ApplyListAppearanceKey.self] }
        set { self[ApplyListAppearanceKey.self] = newValue }
    }
}

// MARK: - Modifiers

extension ScrollView {
    /// When using a `ScrollView`, its contents won't look like rows in a `List` by default.
    ///
    /// Using this modifier will set the custom `applyListAppearance` value to `true` so that the `ListRow` view will apply some additional styling to mimic what a `List` would do.
    func applyPlainListAppearance() -> some View {
        self.environment(\.applyListAppearance, true)
    }
}

extension List {
    /// When using a `List`, it's contents is styled using the `listStyle(_:)` modifier.
    ///
    /// Using this modifier will ensure the correct style is applied and that `ListRow` won't apply any additional styling.
    func applyPlainListAppearance() -> some View {
        self.listStyle(PlainListStyle())
            .environment(\.applyListAppearance, false)
    }
}

// MARK: - Row

/// A wrapper view that will make the content look like a row within a `List` when the `applyListAppearance` `EnvironmentValue` is set.
///
/// This view is used in this tutorial to keep a consistent UI when demonstrating capabilities using either `List` or `ScrollView`.
struct ListRow<Content: View, Background: View>: View {
    private let content: () -> Content
    private let background: () -> Background

    @Environment(\.applyListAppearance) var applyListAppearance

    init(@ViewBuilder background: @escaping () -> Background,
         @ViewBuilder content: @escaping () -> Content
    ) {
        self.background = background
        self.content = content
    }

    init(backgroundColor: Color = Color("csb-main"),
         @ViewBuilder content: @escaping () -> Content) where Background == Color {
        self.init(background: { backgroundColor }, content: content)
    }

    var body: some View {
        if applyListAppearance {
            content()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(background())
        } else {
            content()
                .listRowBackground(background())
        }
    }
}
