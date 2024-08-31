//
//  View+.swift
//  Boleto
//
//  Created by Sunho on 8/16/24.
//

import SwiftUI
extension View {
    func customNavigationBar<C, L> (
        centerView: @escaping (() -> C), leftView: @escaping (() -> L)) -> some View where C: View, L: View {
            modifier(CustomNavigationBarModifier(centerView: centerView, leftView: leftView, rightView: {EmptyView()}))
        }
    func applyBackground() -> some View {
        self.modifier(BackgroundModifier())
    }
    @MainActor
    func captureView(of view: some View, scale: CGFloat = 1.0, size: CGSize? = nil, completion: @escaping (UIImage?) -> Void) {
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        if let size = size {
            renderer.proposedSize = .init(size)
        }
        completion(renderer.uiImage)
    }
    func customTextStyle(_ style: CustomTextStyle) -> some View {
        self.modifier(TextModifier(textStyle: style))
    }
}

struct BackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Color.background.ignoresSafeArea()
            content
        }
    }
}
